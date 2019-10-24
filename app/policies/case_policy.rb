# frozen_string_literal: true

# Case Policy
class CasePolicy < ApplicationPolicy
  def destroy?
    user.admin?
  end
end
