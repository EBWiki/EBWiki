# frozen_string_literal: true

module Admin
  class EthnicitiesController < Admin::ApplicationController
    before_action :set_ethnicity, only: %i[edit update destroy]

    def index
      @ethnicities = Ethnicity.order(:title)
    end

    def new
      @ethnicity = Ethnicity.new
    end

    def create
      @ethnicity = Ethnicity.new(ethnicity_params)
      if @ethnicity.save
        flash[:success] = 'Ethnicity created.'
        redirect_to admin_ethnicities_path
      else
        render :new
      end
    end

    def edit; end

    def update
      if @ethnicity.update(ethnicity_params)
        flash[:success] = 'Ethnicity updated.'
        redirect_to admin_ethnicities_path
      else
        render :edit
      end
    end

    def destroy
      @ethnicity.destroy
      flash[:success] = 'Ethnicity deleted.'
      redirect_to admin_ethnicities_path
    end

    private

    def set_ethnicity
      @ethnicity = Ethnicity.find(params[:id])
    end

    def ethnicity_params
      params.expect(ethnicity: %i[title])
    end
  end
end
