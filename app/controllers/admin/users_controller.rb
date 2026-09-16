# frozen_string_literal: true

module Admin
  class UsersController < Admin::ApplicationController
    def index
      @users = User.order(created_at: :desc)
      if params[:q].present?
        query = "%#{params[:q].strip}%"
        @users = @users.where('name ILIKE :q OR email ILIKE :q', q: query)
      end
      @users = @users.page(params[:page]).per(25)
    end

    def show
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      if @user.update(user_params)
        SendAdminEmail.call(user: @user) if @user.previous_changes.include?('admin')
        flash[:success] = 'User updated.'
        redirect_to admin_user_path(@user)
      else
        render :show
      end
    end

    private

    def user_params
      params.expect(user: %i[admin analyst])
    end
  end
end
