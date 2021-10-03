# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id          :integer          not null, primary key
#  avatar      :string
#  description :text
#  name        :string
#  telephone   :string
#  website     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Organization < ApplicationRecord
end
