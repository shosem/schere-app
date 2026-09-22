module ApplicationHelper
  def header_logo
    if current_guest
      tag.span("Schere", class: "page-section text-brand")
    else
      link_to "Schere", root_path, class: "page-section text-brand"
    end
  end
end
