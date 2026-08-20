# frozen_string_literal: true

module Admin
  class StatesController < Admin::ApplicationController
    before_action :set_state, only: %i[edit update destroy]

    def index
      @states = State.order(:name)
    end

    def new
      @state = State.new
    end

    def create
      @state = State.new(state_params)
      if @state.save
        flash[:success] = 'State created.'
        redirect_to admin_states_path
      else
        render :new
      end
    end

    def edit; end

    def update
      if @state.update(state_params)
        flash[:success] = 'State updated.'
        redirect_to admin_states_path
      else
        render :edit
      end
    end

    def destroy
      if @state.destroy
        flash[:success] = 'State deleted.'
      else
        flash[:error] = @state.errors.full_messages.to_sentence
      end
      redirect_to admin_states_path
    end

    private

    def set_state
      @state = State.find(params[:id])
    end

    def state_params
      params.expect(state: %i[name ansi_code iso])
    end
  end
end
