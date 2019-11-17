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
      icon = content_tag(:i, nil, class: "fas fa-check-circle #{"text-success" if color}") # fa-check-circle fa-check-square
      arrow = false
    elsif data_request_by_status(dataset, "submitted")
      status = "submitted"
      data_request = data_request_by_status(dataset, "submitted")
      text = "Data Request Under Review"
      url = data_request
      icon = content_tag(:i, nil, class: "far fa-comments #{"text-muted" if color}")
      arrow = false
    elsif data_request_by_status(dataset, "resubmit")
      status = "resubmit"
      data_request = data_request_by_status(dataset, "resubmit")
      text = "Resubmit Data Request"
      url = resubmit_data_request_path(data_request)
    elsif data_request_by_status(dataset, "started")
      status = "started"
      data_request = data_request_by_status(dataset, "started")
      text = "Resume Data Request"
      url = resume_data_request_path(data_request)
    elsif expired_data_request(dataset)
      status = "expired"
      text = "Data Request Expired"
      url = data_requests_start_path(dataset)
      icon = content_tag(:i, nil, class: "fas fa-hourglass-end #{"text-muted" if color}")
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
      .where.not(final_legal_document_id: nil)
      .where.not(status: "closed")
  end

  def data_request_by_status(dataset, status)
    data_requests(dataset).not_expired.find_by(status: status)
  end

  def expired_data_request(dataset)
    data_requests(dataset).expired.first
  end

end
