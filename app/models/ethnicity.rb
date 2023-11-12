# frozen_string_literal: true

class Ethnicity < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  has_many :subjects
end

# == Schema Information
#
# Table name: ethnicities
#
#  id         :bigint           not null, primary key
#  slug       :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
