# frozen_string_literal: true

# Generic methods uses across the application views.
module ApplicationHelper
  def simple_check(checked)
    content_tag(:i, "", class: "fa #{checked ? "fa-check-square-o" : "fa-square-o"}")
  end
end
