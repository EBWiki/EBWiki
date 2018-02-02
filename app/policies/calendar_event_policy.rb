# frozen_string_literal: true

# Inintializes CalendarEvent Policy to govern access to event controller actions
class CalendarEventPolicy < ApplicationPolicy
  def index?
    true
  end

  def edit?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    return true if user.present?
  end

  def destroy?
    return true if user.present? && user == calendar_event.user
  end

  private

  def calendar_event
    record
  end
end
