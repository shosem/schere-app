class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  layout :set_layout
  helper_method :current_guest

  private

    def set_layout
      devise_controller? ? "auth" : "application"
    end

    def after_sign_out_path_for(resource_or_scope)
      new_user_session_path   # ログイン画面へ
    end

    def current_guest
      return if user_signed_in?
      @current_guest ||= Guest.find_by(session_token: session[:guest_token])
    end

    # 未ログインの人を省く
    def signed_in!
      redirect_to new_user_session_path, notice: "ログインするか、ゲスト入室リンクから入室してください" unless current_user || current_guest
    end

    # ログイン中のユーザー、もしくはゲストが、そのグループに紐づいているか
    def authorized?(group)
      group.owned_by?(current_user) || current_guest&.group_id == group.id
    end

    # アクセス拒否の行き先
    def deny_access
      redirect_to (current_user ? root_path : group_path(current_guest.group)), alert: "このグループにアクセスする権限がありません"
    end
end
