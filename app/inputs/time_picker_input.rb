# frozen_string_literal: true

# Time Picker for simple_form
class TimePickerInput < DatePickerInput
  private

  def display_pattern
    I18n.t('timepicker.dformat', default: '%R')
  end

  def picker_pattern
    I18n.t('timepicker.pformat', default: 'HH:mm')
  end

  def date_options
    date_options_base
  end
end
