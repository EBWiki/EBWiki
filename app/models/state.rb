# frozen_string_literal: true

# == Schema Information
#
# Table name: states
#
#  id         :integer          not null, primary key
#  ansi_code  :string
#  iso        :string
#  name       :string
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_states_on_ansi_code  (ansi_code)
#  index_states_on_name       (name)
#
# Model representing USA state
class State < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  has_many :cases
  has_many :agencies
  searchkick
end
