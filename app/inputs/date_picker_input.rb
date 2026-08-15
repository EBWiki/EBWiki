# frozen_string_literal: true

# Native date input for simple_form
class DatePickerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    input_html_options[:type] = 'date'
    input_html_options[:value] ||= value&.to_date&.iso8601
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    @builder.text_field(attribute_name, merged_input_options)
  end

  private

  def value
    object.send(attribute_name) if object.respond_to?(attribute_name)
  end
end
