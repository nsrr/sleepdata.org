# frozen_string_literal: true

# Helps display status of agreements
module AgreementsHelper
  def status_helper_simple(agreement)
    content_tag(:span, agreement.status)
  end

  def status_helper(agreement)
    content_tag(
      :span, agreement.status,
      class: "label label-#{status_hash[agreement.status]}"
    )
  end

  def step_helper(agreement, step, selected_step)
    if step == selected_step
      "btn-dark"
    elsif step == 6
      "btn-light"
    elsif agreement.step_valid?(step)
      "btn-dark"
    else
      "btn-light"
    end
  end

  def step_helper_2(agreement, step)
    if step != 6 && agreement.step_valid?(step)
      "fa-check-square-o"
    else
      "fa-square-o"
    end
  end

  def status_hash
    {
      "started" => "warning",
      "submitted" => "info",
      "approved" => "success",
      "resubmit" => "danger",
      "expired" => "default",
      "closed" => "danger"
    }
  end
end
