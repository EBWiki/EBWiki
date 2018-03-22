# frozen_string_literal: true

# The specific ethnicity of the subject
class Ethnicity < ActiveRecord::Base
  has_many :subjects
end
