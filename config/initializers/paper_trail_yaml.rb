# config/initializers/paper_trail_yaml.rb

require 'paper_trail/serializers/yaml'

PERMITTED_CLASSES = [
  Symbol,
  Time,
  Date,
  DateTime,
  BigDecimal,
  ActiveSupport::TimeWithZone,
  ActiveSupport::TimeZone,
  ActiveSupport::Duration
]

PaperTrail::Serializers::YAML.class_eval do
  def load(string)
    return unless string
    YAML.safe_load(
      string,
      permitted_classes: PERMITTED_CLASSES,
      aliases: true
    )
  end
end
