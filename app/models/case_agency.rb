# frozen_string_literal: true

class CaseAgency < ActiveRecord::Base
  belongs_to :case
  belongs_to :agency
end
