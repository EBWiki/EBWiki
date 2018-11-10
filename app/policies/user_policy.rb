# frozen_string_literal: true

# User Policy
class UserPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def update?
    user == record
  end
end
