# frozen_string_literal: true

# == Schema Information
#
# Table name: ethnicities
#
#  id         :integer          not null, primary key
#  slug       :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# The specific ethnicity of the subject
class Ethnicity < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  has_many :subjects
end
