# frozen_string_literal: true

# Helps display access to dataset.
module DatasetsHelper

  def data_access(dataset, color: true)
    text = "View Dataset"
    url = dataset
    icon = nil
    arrow = true
    status = nil
    if data_request_by_status(dataset, "approved")
      text = "Data Access Approved"
      url = files_dataset_path(dataset)
      icon = content_tag(:i, nil, class: "fa fa-check-circle #{"text-success" if color}") # fa-check-circle fa-check-square
      arrow = false
    elsif data_request_by_status(dataset, "submitted")
      status = "submitted"
      data_request = data_request_by_status(dataset, "submitted")
      text = "Data Request Under Review"
      url = data_request
      icon = content_tag(:i, nil, class: "fa fa-comments-o #{"text-muted" if color}")
      arrow = false
    elsif data_request_by_status(dataset, "resubmit")
      status = "resubmit"
      data_request = data_request_by_status(dataset, "resubmit")
      # TODO: Change resubmit data request path
      text = "Resubmit Data Request"
      url = data_requests_proof_path(data_request)
    elsif data_request_by_status(dataset, "started")
      status = "started"
      data_request = data_request_by_status(dataset, "started")
      text = "Resume Data Request"
      url = \
        if data_request.complete?
          data_requests_proof_path(data_request)
        else
          data_requests_page_path(data_request, data_request.current_step.positive? ? data_request.current_step : 1)
        end
    elsif expired_data_request(dataset)
      # data_request = expired_data_request(dataset)
      status = "expired"
      # TODO: Fix "Renew DAUA" path
      text = "Data Request Expired"
      url = data_requests_start_path(dataset)
      icon = content_tag(:i, nil, class: "fa fa-hourglass-end #{"text-muted" if color}")
      arrow = false
    elsif dataset.final_legal_documents.count.positive?
      # Request Data Access
      status = "started"
      text = "Request Data Access"
      url = data_requests_start_path(dataset)
    else
      text = "View Dataset"
      url = dataset
    end
    [text, url, icon, arrow, status]
  end

  private

  def data_requests(dataset)
    dataset
      .data_requests
      .where(user: current_user)
      .where.not(final_legal_document_id: nil, status: "closed")
  end

  def data_request_by_status(dataset, status)
    data_requests(dataset).not_expired.find_by(status: status)
  end

  def expired_data_request(dataset)
    data_requests(dataset).expired.first
  end

end
