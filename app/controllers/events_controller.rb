class EventsController < ApplicationController
  before_action :set_group
  def new
    @event = @group.events.build
    @event.candidate_dates.build
  end

  def create
    @event = @group.events.build(event_paramas)
    @event.user = current_user
    if @event.save
      redirect_to group_path(@group), notice: "イベントを作成しました"
    else
      flash.now[:alert] = "イベントを作成できませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @event = Event.find(params[:id])
  end

  private

  def event_paramas
    params.require(:event).permit(:title, :description, :location, candidate_dates_attributes: [ :id, :date, :start_time, :end_time ])
  end

  def set_group
    @group = current_user.groups.find_by(id: params[:group_id])
    redirect_to root_path, alert: "グループが存在しません" unless @group
  end
end
