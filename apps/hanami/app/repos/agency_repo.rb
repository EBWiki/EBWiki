# frozen_string_literal: true

module EbWiki
  module Repos
    class AgencyRepo < EbWiki::DB::Repo
      def all_ordered
        agencies.order(agencies[:name].asc).to_a
      end

      def find_page(slug)
        record = by_slug(slug)
        return unless record

        case_ids = case_agencies.where(agency_id: record.id).to_a.map(&:case_id)
        related = if case_ids.empty?
          []
        else
          cases.combine(:us_state, :subjects).where(id: case_ids).order(cases[:date].desc).to_a
        end

        {
          record: record,
          state: record.state_id && states.where(id: record.state_id).one,
          cases: related
        }
      end

      def by_slug(slug)
        agencies.where(slug: slug).one
      end

      def name_taken?(name, except_id: nil)
        record = agencies.where(name: name.to_s.strip).one
        record && record.id != except_id
      end

      def validation_errors(attrs, except_id: nil)
        errors = []
        errors << "Name is required" if attrs[:name].to_s.strip.empty?
        errors << "State is required" if attrs[:state_id].to_s.strip.empty?
        errors << "An agency with this name already exists" if name_taken?(attrs[:name], except_id: except_id)
        errors
      end

      def create(attrs)
        now = Time.now.utc
        slug = unique_slug(attrs[:name], attrs[:city], attrs[:street_address])
        id = agencies.insert(agency_row(attrs, slug: slug, now: now))
        agencies.where(id: id).one
      end

      def update(slug, attrs)
        record = by_slug(slug)
        return unless record

        agencies.where(id: record.id).update(
          agency_row(attrs, slug: record.slug, now: Time.now.utc).except(:created_at, :slug)
        )
        agencies.where(id: record.id).one
      end

      private

      def agency_row(attrs, slug:, now:)
        jurisdiction = attrs[:jurisdiction].to_s
        jurisdiction = "unknown" unless %w[unknown local state federal university commercial].include?(jurisdiction)

        {
          name: attrs[:name].to_s.strip,
          street_address: attrs[:street_address].to_s,
          city: attrs[:city].to_s,
          state_id: integer_or_nil(attrs[:state_id]),
          zipcode: attrs[:zipcode].to_s,
          telephone: attrs[:telephone].to_s,
          email: attrs[:email].to_s,
          website: attrs[:website].to_s,
          jurisdiction: jurisdiction,
          slug: slug,
          created_at: now,
          updated_at: now
        }
      end

      def unique_slug(name, city, street)
        candidates = [
          parameterize(name),
          parameterize("#{name} #{city}"),
          parameterize("#{name} #{street} #{city}")
        ].uniq.reject(&:empty?)

        candidates.each do |candidate|
          return candidate unless agencies.where(slug: candidate).one
        end

        "#{candidates.last}-#{Time.now.utc.strftime("%H%M%S")}"
      end

      def parameterize(value)
        value.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
      end

      def integer_or_nil(value)
        return if value.to_s.strip.empty?

        Integer(value)
      rescue ArgumentError
        nil
      end
    end
  end
end
