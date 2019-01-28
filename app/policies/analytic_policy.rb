# frozen_string_literal: true

# Analytic Policy
# rubocop:disable Style/StructInheritance
class AnalyticPolicy < Struct.new(:user, :analytic)
  attr_reader :user, :analytic

  def initialize(user, analytic)
    @user = user
    @analytic = analytic
  end

  def index?
    user.admin? || user.analyst?
  end

  def show?
    user.admin? || user.analyst?
  end
end
# rubocop:enable Style/StructInheritance
