# frozen_string_literal: true

# User Policy
class OrganizationPolicy < ApplicationPolicy
  def edit?
    return false unless user

    user.admin?
  end

  def update?
    user.admin?
  end
end
