# frozen_string_literal: true

# == Schema Information
#
# Table name: genders
#
#  id         :integer          not null, primary key
#  sex        :string
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Encapsulates the many genders that are affected by this
class Gender < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :subjects
  alias_attribute :name, :sex
end
