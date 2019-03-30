# frozen_string_literal: true

# User Policy
class UserPolicy < ApplicationPolicy
  def update?
    user == record || user.admin?
  end
end
