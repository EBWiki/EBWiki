# frozen_string_literal: true

class RolloutHistory < ApplicationRecord
  sanitize :change_description, :author_name
end

# == Schema Information
#
# Table name: rollout_histories
#
#  id                 :bigint           not null, primary key
#  author_name        :string           not null
#  change_date        :date             not null
#  change_description :text             not null
#  rollout_name       :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
