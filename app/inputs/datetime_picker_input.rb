# frozen_string_literal: true

# Datetime Picker for simple_form
class DatetimePickerInput < DatePickerInput
  private

  def display_pattern
    date_format = I18n.t('datepicker.dformat', default: '%d/%m/%Y')
    time_format = I18n.t('timepicker.dformat', default: '%R')
    "#{date_format} #{time_format}"
  end

  def picker_pattern
    date_format = I18n.t('datepicker.pformat', default: 'DD/MM/YYYY')
    time_format = I18n.t('timepicker.pformat', default: 'HH:mm')
    "#{date_format} #{time_format}"
  end
end
