module ApplicationHelper
  def current_guest
    @current_guest ||= Guest.find_by(session_token: session[:guest_token])
  end
end
