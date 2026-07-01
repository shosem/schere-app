class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  layout :set_layout
  include ApplicationHelper

  protected

    def set_layout
      devise_controller? ? "auth" : "application"
    end

    def after_sign_out_path_for(resource_or_scope)
      new_user_session_path   # ログイン画面へ
    end
end
