# frozen_string_literal: true

require 'attribute_sanitizer'

# base class for ActiveRecord objects
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  extend AttributeSanitizer
end
