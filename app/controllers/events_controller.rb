class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy]
  before_action :authenticate_user!, except: %i[show index]

  # GET /events or /events.json
  def index
    @public_events = Event.includes(:host).published.upcoming
    @past_events = Event.includes(:host).past
    @pending_events = current_user.hosted_events.planned if user_signed_in?
  end

  # GET /events/1 or /events/1.json
  def show
    @current_event = Event.find(params[:id])
    @current_guests = @current_event.attendees.all
    @current_user_invite = Invitation.where(attendee_id: current_user.id, event_id: params[:id]).take if user_signed_in?

    respond_to do |format|
      format.html
      format.json { render json: Event.find(params[:id]) }
    end
  end

  # GET /events/new
  def new
    @event = current_user.hosted_events.build
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events or /events.json
  def create
    @event = current_user.hosted_events.build(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to :root, notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to event_url(@event), notice: "Event was successfully updated." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    @event = current_user.hosted_events.find(params[:id])

    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url, notice: "Event was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def event_params
      params.require(:event).permit(:name, :event_date, :open_join, :max_guests, :published)
    end
end
