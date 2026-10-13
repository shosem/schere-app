module ApplicationHelper
  def header_logo
    if current_guest
      tag.span("Schere", class: "page-section text-brand")
    else
      link_to "Schere", root_path, class: "page-section text-brand"
    end
  end

  def page_title(title = "")
    base_title = "Schere"
    title.present? ? "#{title} | #{base_title}" : base_title
  end
end
