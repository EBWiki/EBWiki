# frozen_string_literal: true

module Admin
  class GendersController < Admin::ApplicationController
    before_action :set_gender, only: %i[edit update destroy]

    def index
      @genders = Gender.order(:sex)
    end

    def new
      @gender = Gender.new
    end

    def create
      @gender = Gender.new(gender_params)
      if @gender.save
        flash[:success] = 'Gender created.'
        redirect_to admin_genders_path
      else
        render :new
      end
    end

    def edit; end

    def update
      if @gender.update(gender_params)
        flash[:success] = 'Gender updated.'
        redirect_to admin_genders_path
      else
        render :edit
      end
    end

    def destroy
      @gender.destroy
      flash[:success] = 'Gender deleted.'
      redirect_to admin_genders_path
    end

    private

    def set_gender
      @gender = Gender.find(params[:id])
    end

    def gender_params
      params.expect(gender: %i[sex])
    end
  end
end
