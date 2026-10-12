module ErrorsHelper
  def button_link
    current_guest ? group_path(current_guest.group) : root_path
  end

  def reload_path
    path = request.env["action_dispatch.original_path"]
    return root_path if path.nil?

    path += "?#{request.query_string}" if request.query_string.present?
    path
  end
end
