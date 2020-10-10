# frozen_string_literal: true

# base class for ActiveRecord objects
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
