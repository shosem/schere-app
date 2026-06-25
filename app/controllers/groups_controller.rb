class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: %i[ show destroy ]
  def index
    @groups = current_user.groups
  end

  def new
    @group = Group.new
  end

  def create
    @group = current_user.groups.build(group_params)
    if @group.save
      redirect_to root_path, notice: "グループを作成しました"
    else
      flash.now[:danger] = "グループを作成できませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def destroy
    @group.destroy!
    redirect_to root_path, status: :see_other, notice: "グループを削除しました"
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end

  def set_group
    @group = current_user.groups.find(params[:id])
  end
end
