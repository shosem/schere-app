class GuestSessionsController < ApplicationController
  before_action :set_group
  before_action :redirect_if_joined, only: :new_by_token

  def new_by_token
    @guest = Guest.new
  end

  def create_by_token
    @guest = Guest.find_or_initialize_by(group_id: @group.id, name: params[:guest][:name])

    confirmed = params[:confirmed]

    if @guest.persisted? && !confirmed
      render turbo_stream: turbo_stream.update("confirmation-modal", partial: "guest_sessions/confirmation_modal",
                                                                     locals: { guest: @guest, group: @group })

    elsif @guest.persisted? || @guest.save
      session[:guest_token] = @guest.session_token
      redirect_to group_path(@group), notice: "#{@group.name}に#{@guest.name}さんとして入室しました"
    else
      flash.now[:danger] = "入室できませんでした"
      render :new_by_token, status: :unprocessable_entity
    end
  end

  private

  def set_group
    @group = Group.find_by!(join_token: params[:join_token])
  end

  def redirect_if_joined
    if current_guest && current_guest&.group_id == @group.id
      redirect_to group_path(@group)
    end
  end
end
