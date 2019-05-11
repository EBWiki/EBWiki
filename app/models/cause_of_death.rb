# frozen_string_literal: true

# Cause of death for victims
class CauseOfDeath < ActiveRecord::Base
  has_many :cases
end
