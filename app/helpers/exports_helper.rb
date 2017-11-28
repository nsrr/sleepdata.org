# frozen_string_literal: true

# Helps display export status.
module ExportsHelper
  def export_status_helper(export)
    content_tag(
      :span, export.status,
      class: "badge badge-#{export_status_hash[export.status]}"
    )
  end

  def export_status_hash
    {
      "started" => "warning",
      "completed" => "primary",
      "failed" => "danger"
    }
  end
end
