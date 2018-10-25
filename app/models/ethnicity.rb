# frozen_string_literal: true

# The specific ethnicity of the subject
class Ethnicity < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_many :subjects
end
