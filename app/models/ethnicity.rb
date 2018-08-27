# frozen_string_literal: true

# The specific ethnicity of the subject
class Ethnicity < ApplicationRecord
  has_many :subjects
end
