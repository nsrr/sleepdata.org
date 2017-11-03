# frozen_string_literal: true

# Helps name data requests.
module DataRequestsHelper
  def name_of_datasets(data_request)
    slugs = data_request.datasets.order(:slug).pluck(:slug)
    case slugs.count
    when 0
      badge("-", badge_class: "badge-secondary")
    when 1, 2, 3
      safe_join(slugs.collect { |slug| badge(slug) }, " ")
    else
      count = slugs.count - 2
      safe_join(
        [
          badge(slugs.first),
          badge(slugs.second),
          safe_join([content_tag(:small, "and"), badge("#{count} more", badge_class: "badge-secondary", tooltip: slugs[2..-1].join(", "))], " "),
          # badge(slugs.last)
        ],
        " "
      )
    end
  end

  def badge(slug, badge_class: "badge-dark", tooltip: nil)
    content_tag(
      :span,
      slug,
      class: "badge #{badge_class}",
      rel: "tooltip",
      data: { title: tooltip, container: "body", placement: "top" }
    )
  end
end
