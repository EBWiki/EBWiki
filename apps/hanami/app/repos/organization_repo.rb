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
    end
  end
end
