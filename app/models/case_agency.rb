# frozen_string_literal: true

# Join table between case and agency
class CaseAgency < ApplicationRecord
  belongs_to :case
  belongs_to :agency
end
