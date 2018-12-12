# frozen_string_literal: true

# Generic methods uses across the application views.
module ApplicationHelper
  def simple_check(checked)
    checked ? icon("fas", "check-square") : icon("far", "square")
  end
end
