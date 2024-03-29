class InvitationsController < ApplicationController
  before_action :set_invitation, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /invitations or /invitations.json
  def index
    @invitations = Invitation.all
  end

  # GET /invitations/1 or /invitations/1.json
  def show
  end

  # GET /invitations/new
  def new
    event = Event.find(params[:event_id])
    redirect_to :root, alert: 'Event is currently not accepting more attendees.' unless event.open_join
    redirect_to :root, alert: 'Event is in the past.' unless event.event_date >= DateTime.now

    @invitation = current_user.invitations.build
  end

  # GET /invitations/1/edit
  def edit
  end

  # POST /invitations or /invitations.json
  def create
    event = Event.find(params[:invitation][:event_id])
    redirect_to :root, alert: 'Event is currently not accepting more attendees.' unless event.open_join || event.to_come

    @invitation = current_user.invitations.build(invitation_params)

    respond_to do |format|
      if @invitation.save
        format.html { redirect_to :root, notice: 'You joined the event!' }
        format.json { render :show, status: :created, location: @invitation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invitations/1 or /invitations/1.json
  def update
    respond_to do |format|
      if @invitation.update(invitation_params)
        format.html { redirect_to invitation_url(@invitation), notice: "Invitation was successfully updated." }
        format.json { render :show, status: :ok, location: @invitation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invitations/1 or /invitations/1.json
  def destroy
    @invitation.destroy

    respond_to do |format|
      format.html { redirect_to :root, notice: 'You are no longer an attendee of that event.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invitation
      @invitation = Invitation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def invitation_params
      params.require(:invitation).permit(:event_id, :attendee_id)
    end
end
