# frozen_string_literal: true

module Admin
  class ApplicationController < ::ApplicationController
    layout 'admin'
    before_action :authenticate_staff!

    private

    def authenticate_staff!
      return if current_user&.admin?

      flash[:error] = 'You are not an admin'
      redirect_to root_path
    end
  end
end
