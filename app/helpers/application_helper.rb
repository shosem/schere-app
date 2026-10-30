module ApplicationHelper
  def header_logo
    if current_guest
      tag.span("Schere", class: "page-section text-brand")
    else
      link_to "Schere", root_path, class: "page-section text-brand"
    end
  end

  # メタタグや動的なOGP
  def default_meta_tags
    base_title = "Schere"
    title = content_for(:title)
    description = "イベント作成から日程調整まで"
    {
      site: base_title,
      title: title,
      reverse: true,
      charset: "UTF-8",
      description: description,
      keywords: "予定 日程 調整 幹事 イベント",
      og: {
        site_name: base_title,
        title: title,
        description: description,
        url: request.original_url,
        image: "#{request.base_url}/ogp/light.png",
        locale: "ja-JP"
      },
      twitter: {
        card: "summary_large_image",
        image: "#{request.base_url}/ogp/light.png"
      }
    }
  end
end
