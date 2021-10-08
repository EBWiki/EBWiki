# frozen_string_literal: true

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
# Join table between case and agency
class CaseAgency < ApplicationRecord
  belongs_to :case
  belongs_to :agency
end
