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
