# frozen_string_literal: true

# Helper for the agencies page
module AgenciesHelper
  def show_non_blank_fields(label, value)
    "#{label}: #{value}" if value.present?
  end

  def link_to_name(agency)
    link_to(truncate(agency.name, length: 50), agency_path(agency.id))
  end

  def link_to_edit(agency)
    link_to('Edit', edit_agency_path(agency.id))
  end
end
