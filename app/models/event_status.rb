# frozen_string_literal: true

# == Schema Information
#
# Table name: event_statuses
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class EventStatus < ApplicationRecord
end
