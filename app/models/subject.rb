# frozen_string_literal: true

class Subject < ApplicationRecord
  belongs_to :case
  belongs_to :gender
  belongs_to :ethnicity

  # Model validations
  sanitize :name

  validates :name, presence: { message: 'Name of the victim can\'t be blank.' }
end

# == Schema Information
#
# Table name: subjects
#
#  id           :integer          not null, primary key
#  age          :integer
#  homeless     :boolean
#  mentally_ill :boolean
#  name         :string           not null
#  unarmed      :boolean
#  veteran      :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  case_id      :integer
#  ethnicity_id :integer
#  gender_id    :integer
#
# Foreign Keys
#
#  fk_rails_...  (case_id => cases.id) ON DELETE => cascade
#

