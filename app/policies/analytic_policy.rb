# frozen_string_literal: true

# User Policy
class AnalyticPolicy < Struct.new(:user, :analytic)
  attr_reader :user, :analytic

  def initialize(user, analytic)
    @user = user
    @analytic = analytic
  end

  def index?
    user.admin? or user.analyst?
  end

  def show?
    user.admin? or user.analyst?
  end
end
