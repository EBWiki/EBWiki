module ConversationsHelper
  def other_users_to_message(form)
    form.select(:recipients, @other_users.collect {|p| [ p.name, p.id ] }, {}, { multiple: true , class: "form-control select2", multiple:"multiple", placeholder: "Select other EBWiki users to message" })
  end
end