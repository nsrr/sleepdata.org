# frozen_string_literal: true

# Methods to sort tables in various ways.
module SortHelper
  # TODO: Deprecate in favor of "order_link"
  def th_sort_field_rev(order, sort_field, display_name, extra_class: "")
    sort_params = params.permit(:search)
    sort_field_order = (order == "#{sort_field} desc" || order == "#{sort_field} desc nulls last") ? sort_field : "#{sort_field} desc"
    if order == sort_field
      selected_class = "sort-selected"
    elsif order == "#{sort_field} desc nulls last" || order == "#{sort_field} desc"
      selected_class = "sort-selected"
    end
    content_tag(:th, class: [selected_class, extra_class]) do
      link_to url_for(sort_params.merge(order: sort_field_order)), style: "text-decoration: none;" do
        display_name.to_s.html_safe
      end
    end.html_safe
  end

  # TODO: Deprecate in favor of "order_link"
  def th_sort_field(order, sort_field, display_name, extra_class: "")
    sort_params = params.permit(:search)
    sort_field_order = (order == sort_field) ? "#{sort_field} desc" : sort_field
    if order == sort_field
      selected_class = "sort-selected"
    elsif order == "#{sort_field} desc nulls last" || order == "#{sort_field} desc"
      selected_class = "sort-selected"
    end
    content_tag(:th, class: [selected_class, extra_class]) do
      link_to url_for(sort_params.merge(order: sort_field_order)), style: "text-decoration: none;" do
        display_name.to_s.html_safe
      end
    end.html_safe
  end

  def order_to(title, primary: "", secondary: "#{primary} desc")
    sort_params = params.permit(:search)
    sort_field_order = (params[:order] == primary ? secondary : primary)
    link_class = params[:order].in?([primary, secondary].compact) ? "link-accent" : nil
    link_to title, url_for(sort_params.merge(order: sort_field_order)), class: link_class
  end
end
