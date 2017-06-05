module AgenciesHelper
  def show_non_blank_fields(label, value)
    "#{label}: #{value}" if !value.blank?
  end
  
  def link_to_name(agency)
    link_to(truncate(agency.name, length: 30), agency)
  end
  
  def agency_updated_at(agency)
    agency.updated_at.strftime("%m.%e, %l:%M %p")
  end
  
  def link_to_edit(agency)
    link_to('Edit', edit_agency_path(agency))
  end
    
end