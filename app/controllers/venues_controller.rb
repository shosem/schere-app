class VenuesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_event

  def new
    @venue = @event.venues.build
  end

  def create
    @venue = @event.venues.build(venue_params)
    if @venue.save
      redirect_to group_event_path(@group, @event)
    else
      redirect_back fallback_location: group_event_path(@group, @event), alert: "予約情報を登録できませんでした"
    end
  end

  def edit
    @venue = @event.venues.find(params[:id])
  end

  def update
    @venue = @event.venues.find(params[:id])
    if @venue.update(venue_params)
      redirect_to group_event_path(@group, @event)
    else
      redirect_back fallback_location: group_event_path(@group, @event), alert: "予約情報を更新できませんでした"
    end
  end

  def destroy
    @venue = @event.venues.find(params[:id])
    @venue.destroy!
    redirect_to group_event_path(@group, @event)
  end

  private

  def venue_params
    params.require(:venue).permit(:name, :page_url, :price, :note, :reserved)
  end

  def set_group
    @group = Group.find(params[:group_id])
    deny_access unless authorized?(@group)
  end

  def set_event
    @event = @group.events.find(params[:event_id])
  end
end
