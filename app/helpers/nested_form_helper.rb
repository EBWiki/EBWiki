# frozen_string_literal: true

module NestedFormHelper
  def link_to_add_association(name, form, association, html_options = {})
    new_object = form.object.class.reflect_on_association(association).klass.new
    fields = form.simple_fields_for(association, new_object, child_index: 'NEW_RECORD') do |builder|
      render(html_options.delete(:partial) || "#{association.to_s.singularize}_fields", f: builder)
    end

    html_options[:data] ||= {}
    html_options[:data][:action] = 'nested-form#add'
    content_tag(:template, fields, data: { nested_form_target: 'template' }) +
      link_to(name, '#', html_options)
  end

  def link_to_remove_association(name, form, html_options = {})
    html_options[:data] ||= {}
    html_options[:data][:action] = 'nested-form#remove'
    safe_join([form.hidden_field(:_destroy), link_to(name, '#', html_options)])
  end
end
