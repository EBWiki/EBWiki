# frozen_string_literal: true

class AnalyticsPolicy < ApplicationPolicy
  def index?
    user.admin? || user.analyst?
  end
end
