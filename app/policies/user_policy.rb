# frozen_string_literal: true

# User Policy
class UserPolicy < ApplicationPolicy
  def edit?
    return false unless user

    user == record || user.admin?
  end

  def update?
    user == record || user.admin?
  end
end
