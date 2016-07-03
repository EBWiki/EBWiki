module AgenciesHelper
  def show_non_blank_fields(label, value)
    "#{label}: #{value}" if !value.blank?
  end
end