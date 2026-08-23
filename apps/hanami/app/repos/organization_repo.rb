# frozen_string_literal: true

module EbWiki
  module Repos
    class OrganizationRepo < EbWiki::DB::Repo
      def all_ordered
        organizations.order(organizations[:name].asc).to_a
      end

      def by_id(id)
        organizations.where(id: id).one
      end

      def create(attrs)
        now = Time.now.utc
        id = organizations.insert(org_row(attrs, now: now))
        organizations.where(id: id).one
      end

      def update(id, attrs)
        record = by_id(id)
        return unless record

        organizations.where(id: record.id).update(org_row(attrs, now: Time.now.utc).except(:created_at))
        organizations.where(id: record.id).one
      end

      private

      def org_row(attrs, now:)
        {
          name: attrs[:name].to_s.strip,
          description: attrs[:description].to_s,
          website: attrs[:website].to_s,
          telephone: attrs[:telephone].to_s,
          created_at: now,
          updated_at: now
        }
      end
    end
  end
end
