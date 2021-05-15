# frozen_string_literal: true

# This module sanitizes user input
module AttributeSanitizer
  def sanitize(*attributes)
    before_validation do
      attributes.flatten.each do |attribute|
        next unless public_send(attribute)

        sanitized_value = public_send(attribute).strip.delete_suffix(',')
        public_send("#{attribute}=", sanitized_value)
      end
    end
  end
end
