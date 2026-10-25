# frozen_string_literal: true

# Case Policy
class CasePolicy < ApplicationPolicy
  def update?
    user.admin?
  end

  def edit?
    update?
  end

  def destroy?
    user.admin?
  end

  def revert?
    user.admin?
  end
end
