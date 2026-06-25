class GroupsController < ApplicationController
  before_action :authenticate_user!
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

  def show
    @group = current_user.groups.find(params[:id])
  end

  private

  def group_params
    params.require(:group).permit(:name)
  end
end
