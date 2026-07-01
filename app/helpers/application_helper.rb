module ApplicationHelper
  def header_logo
    if current_guest
      tag.span("Schere", class: "text-xl font-bold text-blue-500")
    else
      link_to "Schere", root_path, class: "text-xl font-bold text-blue-500"
    end
  end
end
