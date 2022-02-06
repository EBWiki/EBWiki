# frozen_string_literal: true

class CaseAgency < ApplicationRecord
  belongs_to :case
  belongs_to :agency
end
# == Schema Information
#
# Table name: case_agencies
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  agency_id  :integer
#  case_id    :integer
#
