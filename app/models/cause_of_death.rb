# frozen_string_literal: true

# Cause of death for victims
class CauseOfDeath < ApplicationRecord
  has_many :cases
end
