class GuestSessionsController < ApplicationController
  before_action :set_group

  def new_by_token
    @guest = Guest.new
  end

  def create_by_token
    @guest = Guest.find_or_initialize_by(group_id: @group.id, name: params[:guest][:name])

    if @guest.persisted? || @guest.save
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
end
