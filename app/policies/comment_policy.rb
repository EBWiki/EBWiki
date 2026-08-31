# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def destroy?
    user&.admin?
  end
end
