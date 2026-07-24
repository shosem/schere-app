class EventConfirmationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_event
  def update

    @candidate_date = @event.candidate_dates.find(params[:candidate_date_id])

    @event.update!(confirmed_candidate_date_id: @candidate_date.id, status: :confirmed)
    redirect_to group_event_path(@group, @event), notice: "日程を確定しました"
  end

  def destroy
    @event.update!(confirmed_candidate_date_id: nil, status: :adjusting)
    redirect_to group_event_path(@group, @event), notice: "調整中に戻しました"
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
    # authorized?はユーザーログインならオーナー判定をしてる
    deny_access unless authorized?(@group)
  end

  def set_event
    @event = @group.events.find(params[:event_id])
  end
end
