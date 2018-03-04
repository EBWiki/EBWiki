# frozen_string_literal: true

class Subject < ActiveRecord::Base
  belongs_to :article
  belongs_to :gender
  belongs_to :ethnicity
  validates :name, presence: { message: 'Name of the victim can\'t be blank.' }
end
