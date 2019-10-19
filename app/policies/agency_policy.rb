# frozen_string_literal: true

# Agency Policy
class AgencyPolicy < ApplicationPolicy
  def destroy?
    user.admin?
  end
end
