# frozen_string_literal: true.

class UserPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @user = model
  end

  def index?
    @current_user == @user
  end

  def show?
    @current_user == @user
  end

  def edit?
    @current_user == @user
  end

  def new?
    create?
  end

  def update?
    @current_user == @user
  end

  def destroy?
    return false if @current_user == @user
  end
end
