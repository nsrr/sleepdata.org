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
    elsif dataset.disable_data_requests?
      text = "Dataset Unavailable for New Requests"
      url = dataset
      icon = content_tag(:i, nil, class: "fas fa-exclamation-triangle #{"text-warning" if color}")
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
    elsif final_legal_documents?(dataset)
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

  # Loads everything data_access needs for a list of datasets in two queries, instead of up to
  # six per call (the index renders data_access twice per card: ~420 queries for 35 cards).
  def preload_data_access(datasets)
    ids = datasets.map(&:id)
    return if ids.empty?

    @data_access_requests ||= {}
    @data_access_final_docs ||= {}
    requests_by_dataset = \
      if current_user
        DataRequest.current
                   .joins(:requests)
                   .where(requests: { dataset_id: ids }, user: current_user)
                   .where.not(final_legal_document_id: nil)
                   .where.not(status: "closed")
                   .select("agreements.*, requests.dataset_id AS access_dataset_id")
                   .group_by(&:access_dataset_id)
      else
        {}
      end
    final_doc_counts = FinalLegalDocument.current
                                         .joins(legal_document: :legal_document_datasets)
                                         .where(legal_document_datasets: { dataset_id: ids })
                                         .group("legal_document_datasets.dataset_id")
                                         .count
    ids.each do |id|
      @data_access_requests[id] = requests_by_dataset[id] || []
      @data_access_final_docs[id] = final_doc_counts[id].to_i
    end
  end

  private

  def data_access_requests(dataset)
    preload_data_access([dataset]) unless @data_access_requests&.key?(dataset.id)
    @data_access_requests[dataset.id]
  end

  def final_legal_documents?(dataset)
    preload_data_access([dataset]) unless @data_access_final_docs&.key?(dataset.id)
    @data_access_final_docs[dataset.id].positive?
  end

  def data_request_by_status(dataset, status)
    today = Time.zone.today
    data_access_requests(dataset)
      .select { |r| r.status == status && (r.expiration_date.nil? || r.expiration_date >= today) }
      .min_by(&:id)
  end

  def expired_data_request(dataset)
    today = Time.zone.today
    data_access_requests(dataset)
      .select { |r| r.expiration_date && r.expiration_date < today }
      .min_by(&:id)
  end
end
