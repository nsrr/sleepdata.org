# frozen_string_literal: true

# TODO: Remove or refactor

# Helps display status of agreements
module AgreementsHelper
  def status_helper(agreement)
    content_tag(
      :span, agreement.status,
      class: "badge badge-#{status_hash[agreement.status]}"
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

  def status_hash
    {
      "started" => "warning",
      "submitted" => "primary",
      "approved" => "success",
      "resubmit" => "danger",
      "expired" => "light",
      "closed" => "danger"
    }
  end
end
