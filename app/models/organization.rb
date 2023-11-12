# frozen_string_literal: true

class Organization < ApplicationRecord
end

# == Schema Information
#
# Table name: organizations
#
#  id          :bigint           not null, primary key
#  avatar      :string
#  description :text
#  name        :string
#  telephone   :string
#  website     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
