# frozen_string_literal: true

# governs calendar event controller actions
class CalendarEventsController < ApplicationController
  before_action :set_calendar_event, only: %i[show edit update destroy]

  # GET /calendar_events
  # GET /calendar_events.json
  def index
    @calendar_events = CalendarEvent.all
    authorize @calendar_events
  end

  # GET /calendar_events/1
  # GET /calendar_events/1.json
  def show
    @event_owner = @calendar_event.user
  end

  # GET /calendar_events/new
  def new
    @calendar_event = CalendarEvent.new
    authorize @calendar_event

    respond_to do |format|
      format.html { render partial: 'new' }
      format.js
    end
  end

  # GET /calendar_events/1/edit
  def edit
    authorize @calendar_event
    respond_to do |format|
      format.html { render partial: 'edit' }
      format.js
    end
  end

  # POST /calendar_events
  # POST /calendar_events.json
  def create
    @calendar_event = CalendarEvent.new(calendar_event_params)
    @calendar_event.user = current_user
    authorize @calendar_event
    respond_to do |format|
      if @calendar_event.save
        format.html { redirect_to @calendar_event,
                      notice: 'Calendar event was successfully created.'
        }
        format.json { render :show, status: :created, location: @calendar_event
        }
      else
        format.html { render partial: 'new' }
        format.json { render json: @calendar_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /calendar_events/1
  # PATCH/PUT /calendar_events/1.json
  def update
    respond_to do |format|
      if @calendar_event.update(calendar_event_params)
        format.html { redirect_to @calendar_event,
                    notice: 'Calendar event was successfully updated.' }
        format.json { render json: @calendar_event,
                    :status => :created,
                    location: @calendar_event
        }
      else
        format.html { render partial: 'edit' }
        format.json { render json: @calendar_event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /calendar_events/1
  # DELETE /calendar_events/1.json
  def destroy
    @calendar_event.destroy
    respond_to do |format|
      format.html {
        redirect_to calendar_events_url,
        notice: 'Calendar event was successfully destroyed.'
      }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_calendar_event
      @calendar_event = CalendarEvent.find(params[:id])
      authorize @calendar_event
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def calendar_event_params
      params.require(:calendar_event).permit(
        :title,
        :description,
        :start_time,
        :end_time,
        :latitude,
        :longitude, :slug, :address, :city, :state_id, :zipcode, :user_id
                                            )
    end
end
