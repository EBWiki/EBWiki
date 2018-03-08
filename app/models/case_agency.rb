# frozen_string_literal: true

# Join table between case and agency
class CaseAgency < ActiveRecord::Base
  belongs_to :case
  belongs_to :agency
end
