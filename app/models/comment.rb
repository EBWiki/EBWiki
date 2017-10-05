# frozen_string_literal: true

class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :user
end
