class GroupsController < ApplicationController
  before_action :signed_in!, only: :show
  before_action :authenticate_user!, except: :show
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
    @group = Group.find(params[:id])
    deny_access unless authorized?(@group)
  end

  # 未ログインの人を省く
  def signed_in!
    redirect_to new_user_session_path, notice: "ログインするか、ゲスト入室リンクから入室してください" unless current_user || current_guest
  end

  # ログイン中のユーザー、もしくはゲストが、そのグループに紐づいているか
  def authorized?(group)
    current_user&.id == group.user_id || current_guest&.group_id == group.id
  end

  # アクセス拒否の行き先
  def deny_access
    redirect_to (current_user ? root_path : group_path(current_guest.group)), alert: "このグループにアクセスする権限がありません"
  end
end
