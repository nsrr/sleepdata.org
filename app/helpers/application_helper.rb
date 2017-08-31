# frozen_string_literal: true

# Generic methods uses across the application views.
module ApplicationHelper
  def cancel
    url = \
      if URI.parse(request.referer.to_s).path.blank?
        root_path
      else
        URI.parse(request.referer.to_s).path
      end
    link_to(
      "Cancel",
      url,
      class: "btn btn-light"
    )
  end

  def simple_check(checked)
    content_tag(:i, "", class: "fa #{checked ? "fa-check-square-o" : "fa-square-o"}")
  end
end
