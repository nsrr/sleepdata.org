# frozen_string_literal: true

# Override for devise confirmations controller.
class ConfirmationsController < Devise::ConfirmationsController
  layout "layouts/full_page"

  def after_confirmation_path_for(resource_name, resource)
    sign_in(resource)
    if params[:data_request_id].present?
      resume_data_request_path(params[:data_request_id])
    else
      dashboard_path
    end
  end
end
