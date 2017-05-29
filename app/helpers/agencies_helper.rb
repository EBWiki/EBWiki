module AgenciesHelper
  def show_non_blank_fields(label, value)
    "#{label}: #{value}" if !value.blank?
  end
  
  def agencies_list
    html = ""
    Agency.all.each_with_index do |agency, i|
      link_to_name = link_to(truncate(agency.name, length: 30), agency)
      updated_at = agency.updated_at.strftime("%m.%e, %l:%M %p")
      link_to_edit = link_to('Edit', edit_agency_path(agency))
      
      html += "<tr>
        <td>#{i + 1}</td>
        <td>#{link_to_name}</td>
        <td><small>#{updated_at}</small></td>
        <td>#{link_to_edit}</td>
      </tr>"
    end
    
    return raw(html)
  end
end