# frozen_string_literal: true

require "yaml"

module EbWiki
  module Repos
    class CaseRepo < EbWiki::DB::Repo
      PAGE_SIZE = 12
      RECENT_LIMIT = 10
      YAML_PERMITTED = [Date, Time, DateTime, Symbol].freeze
      REVERTABLE_COLUMNS = %i[
        title date state_id city address zipcode longitude latitude
        video_url overview community_action litigation country summary blurb
        cause_of_death
      ].freeze

      def homepage(page: 1)
        page_number = [page.to_i, 1].max

        cases
          .combine(:us_state, :subjects)
          .order(cases[:date].desc)
          .page(page_number)
          .per_page(PAGE_SIZE)
          .to_a
      end

      def recently_updated(limit: RECENT_LIMIT)
        cases.order(cases[:updated_at].desc).limit(limit).to_a
      end

      def total_count
        cases.count
      end

      def find_page(slug)
        record = cases.where(slug: slug).one
        return unless record

        {
          record: record,
          state: record.state_id && states.where(id: record.state_id).one,
          subjects: subjects.where(case_id: record.id).to_a,
          agencies: agencies_for(record.id),
          links: links
            .where(linkable_type: "Case", linkable_id: record.id)
            .order(links[:created_at].desc)
            .to_a
        }
      end

      def search(query:, page: 1, state_id: nil)
        rel = cases.combine(:us_state, :subjects)
        rel = rel.where(state_id: Integer(state_id)) if state_id.to_s.match?(/\A\d+\z/)

        q = query.to_s.strip
        rel = apply_search(rel, q) unless q.empty?

        rel.order(cases[:date].desc)
          .page([page.to_i, 1].max)
          .per_page(PAGE_SIZE)
          .to_a
      end

      def search_count(query:, state_id: nil)
        rel = cases
        rel = rel.where(state_id: Integer(state_id)) if state_id.to_s.match?(/\A\d+\z/)
        q = query.to_s.strip
        rel = apply_search(rel, q) unless q.empty?
        rel.count
      end

      def history_for(slug)
        record = cases.where(slug: slug).one
        return unless record

        versions = self.versions
          .where(item_type: "Case", item_id: record.id)
          .order(self.versions[:created_at].desc)
          .to_a

        author_ids = versions.map { |version| version.author_id || integer_or_nil(version.whodunnit) }
        {record: record, versions: versions, authors: users_by_id(author_ids)}
      end

      def comments_for(case_id)
        comments
          .where(commentable_type: "Case", commentable_id: case_id)
          .order(comments[:created_at].desc)
          .to_a
      end

      def users_by_id(ids)
        ids = ids.compact.uniq
        return {} if ids.empty?

        users.where(id: ids).to_a.each_with_object({}) do |user, hash|
          hash[user.id] = user
        end
      end

      def add_comment(case_id:, user_id:, content:)
        now = Time.now.utc
        comments.insert(
          commentable_type: "Case",
          commentable_id: case_id,
          user_id: user_id,
          content: content.to_s,
          created_at: now,
          updated_at: now
        )
      end

      def delete_comment(comment_id, actor:)
        comment = comments.where(id: comment_id).one
        return unless comment
        return unless actor && (actor.admin || comment.user_id == actor.id)

        comments.where(id: comment_id).delete
        comment
      end

      def comment_case_slug(comment)
        return unless comment&.commentable_type == "Case"

        cases.where(id: comment.commentable_id).one&.slug
      end

      def following?(case_id:, user_id:)
        !follows.where(
          followable_type: "Case",
          followable_id: case_id,
          follower_type: "User",
          follower_id: user_id,
          blocked: false
        ).one.nil?
      end

      def follow(case_id:, user_id:)
        return if following?(case_id: case_id, user_id: user_id)

        now = Time.now.utc
        follows.insert(
          followable_type: "Case",
          followable_id: case_id,
          follower_type: "User",
          follower_id: user_id,
          blocked: false,
          created_at: now,
          updated_at: now
        )
        bump_follows(case_id, 1)
      end

      def unfollow(case_id:, user_id:)
        deleted = follows.where(
          followable_type: "Case",
          followable_id: case_id,
          follower_type: "User",
          follower_id: user_id
        ).delete
        bump_follows(case_id, -deleted) if deleted.positive?
      end

      def create_with_children(attrs, user:)
        now = Time.now.utc
        slug = unique_slug(attrs[:title], attrs[:city], attrs[:zipcode])
        case_id = nil

        db.transaction do
          case_id = cases.insert(case_row(attrs, slug: slug, now: now))
          write_children(case_id, attrs, now: now)
          record_version(case_id, event: "create", comment: attrs[:summary], user: user, now: now)
        end

        cases.where(id: case_id).one
      end

      def update_with_children(slug, attrs, user:)
        record = cases.where(slug: slug).one
        return unless record

        now = Time.now.utc
        before = snapshot_case(record)
        db.transaction do
          cases.where(id: record.id).update(
            case_row(attrs, slug: record.slug, now: now).except(:created_at, :slug)
          )
          subjects.where(case_id: record.id).delete
          links.where(linkable_type: "Case", linkable_id: record.id).delete
          case_agencies.where(case_id: record.id).delete
          write_children(record.id, attrs, now: now)
          record_version(
            record.id,
            event: "update",
            comment: attrs[:summary],
            user: user,
            now: now,
            object: dump_object(before)
          )
        end

        cases.where(id: record.id).one
      end

      def revert_to_version(slug, version_id, user:)
        record = cases.where(slug: slug).one
        return unless record

        version = versions
          .where(id: Integer(version_id), item_type: "Case", item_id: record.id)
          .one
        return unless version

        attrs = load_object(version.object)
        return :no_snapshot unless attrs.is_a?(Hash)

        now = Time.now.utc
        updates = reverted_columns(attrs)
        updates[:updated_at] = now
        updates[:summary] = "Reverted to version #{version.id}"

        db.transaction do
          before = snapshot_case(cases.where(id: record.id).one)
          cases.where(id: record.id).update(updates)
          record_version(
            record.id,
            event: "update",
            comment: "Reverted to version #{version.id}",
            user: user,
            now: now,
            object: dump_object(before)
          )
        end

        cases.where(id: record.id).one
      end

      private

      def db
        cases.dataset.db
      end

      def case_row(attrs, slug:, now:)
        {
          title: attrs[:title].to_s,
          slug: slug,
          city: attrs[:city].to_s,
          address: attrs[:address].to_s,
          zipcode: attrs[:zipcode].to_s,
          state_id: integer_or_nil(attrs[:state_id]),
          date: attrs[:date],
          overview: attrs[:overview].to_s,
          litigation: attrs[:litigation].to_s,
          community_action: attrs[:community_action].to_s,
          blurb: attrs[:blurb].to_s,
          summary: attrs[:summary].to_s,
          video_url: attrs[:video_url].to_s,
          cause_of_death: normalize_cause(attrs[:cause_of_death]),
          created_at: now,
          updated_at: now
        }
      end

      def write_children(case_id, attrs, now:)
        Array(attrs[:subjects]).each do |subject|
          name = subject[:name].to_s.strip
          next if name.empty?

          subjects.insert(
            case_id: case_id,
            name: name,
            age: integer_or_nil(subject[:age]),
            created_at: now,
            updated_at: now
          )
        end

        Array(attrs[:links]).each do |link|
          url = link[:url].to_s.strip
          next if url.empty?

          links.insert(
            linkable_type: "Case",
            linkable_id: case_id,
            url: url,
            title: link[:title].to_s,
            created_at: now,
            updated_at: now
          )
        end

        Array(attrs[:agency_ids]).each do |agency_id|
          id = integer_or_nil(agency_id)
          next unless id

          case_agencies.insert(
            case_id: case_id,
            agency_id: id,
            created_at: now,
            updated_at: now
          )
        end
      end

      def record_version(case_id, event:, comment:, user:, now:, object: nil)
        versions.insert(
          item_type: "Case",
          item_id: case_id,
          event: event,
          comment: comment.to_s,
          whodunnit: user&.id&.to_s,
          author_id: user&.id,
          object: object,
          created_at: now
        )
      end

      def snapshot_case(record)
        REVERTABLE_COLUMNS.each_with_object({}) do |column, hash|
          hash[column.to_s] = record.public_send(column) if record.respond_to?(column)
        end
      end

      def dump_object(hash)
        YAML.dump(hash)
      end

      def load_object(yaml)
        return if yaml.to_s.strip.empty?

        YAML.safe_load(
          yaml,
          permitted_classes: YAML_PERMITTED,
          aliases: true
        )
      rescue Psych::Exception
        nil
      end

      def reverted_columns(attrs)
        REVERTABLE_COLUMNS.each_with_object({}) do |column, hash|
          key = attrs.key?(column.to_s) ? column.to_s : column
          next unless attrs.key?(key)

          hash[column] = attrs[key]
        end
      end

      def unique_slug(title, city, zipcode)
        candidates = [
          parameterize(title),
          parameterize("#{title} #{city}"),
          parameterize("#{title} #{city} #{zipcode}")
        ].uniq.reject(&:empty?)

        candidates.each do |candidate|
          return candidate unless cases.where(slug: candidate).one
        end

        "#{candidates.last}-#{now_token}"
      end

      def parameterize(value)
        value.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
      end

      def now_token
        Time.now.utc.strftime("%H%M%S")
      end

      def integer_or_nil(value)
        return if value.to_s.strip.empty?

        Integer(value)
      rescue ArgumentError
        nil
      end

      def normalize_cause(value)
        return if value.to_s.empty?

        {
          "medical_neglect" => "medical neglect",
          "response_to_medical_emergency" => "response to medical emergency"
        }.fetch(value.to_s, value.to_s)
      end

      def bump_follows(case_id, delta)
        cases.where(id: case_id).update(follows_count: Sequel[:follows_count] + delta)
      rescue Sequel::Error
        nil
      end


      def agencies_for(case_id)
        agency_ids = case_agencies.where(case_id: case_id).to_a.map(&:agency_id)
        return [] if agency_ids.empty?

        agencies.where(id: agency_ids).to_a
      end

      def apply_search(rel, query)
        if cases.dataset.columns.include?(:tsv)
          rel.where(Sequel.lit("tsv @@ plainto_tsquery('english', ?)", query))
        else
          pattern = "%#{self.class.escape_like(query)}%"
          rel.where(
            Sequel.lit(
              "title ILIKE ? OR city ILIKE ? OR overview ILIKE ? OR COALESCE(blurb, '') ILIKE ?",
              pattern, pattern, pattern, pattern
            )
          )
        end
      end

      def self.escape_like(value)
        value.gsub(/[%_\\]/) { |char| "\\#{char}" }
      end
    end
  end
end
