# frozen_string_literal: true

# Allows users to request access to one or more datasets.
class DataRequest < Agreement
  # Relationships
  has_many :supporting_documents

  def organization_available?
    final_legal_document.data_user_type == "individual" &&
      associated_legal_documents.where(data_user_type: ["both", "organization"]).present?
  end

  def individual_available?
    final_legal_document.data_user_type == "organization" &&
      associated_legal_documents.where(data_user_type: ["both", "individual"]).present?
  end

  def commercial_available?
    final_legal_document.commercial_type == "noncommercial" &&
      associated_legal_documents.where(commercial_type: ["both", "commercial"]).present?
  end

  def noncommercial_available?
    final_legal_document.commercial_type == "commercial" &&
      associated_legal_documents.where(commercial_type: ["both", "noncommercial"]).present?
  end

  def associated_legal_documents
    dataset_ids = datasets.pluck(:id)
    array = []
    final_legal_document.organization.legal_documents.joins(:legal_document_datasets).published.each do |legal_document|
      array << legal_document.id if (dataset_ids - legal_document.datasets.pluck(:id)).empty?
    end
    final_legal_document.organization.legal_documents.where(id: array)
  end

  def page_complete?(final_legal_document_page)
    (response_count, variable_count) = coverage(final_legal_document_page)
    response_count == variable_count
  end

  def pages_complete?
    final_legal_document.final_legal_document_pages.each do |page|
      return false unless page_complete?(page)
    end
    true
  end

  def attestation_required?
    %w(checkbox signature).include?(final_legal_document.attestation_type)
  end

  def signature_required?
    final_legal_document.attestation_type == "signature"
  end

  def attestation_complete?
    case final_legal_document.attestation_type
    when "signature"
      signature_file.present? || duly_authorized_representative_signature_file.present?
    else
      false
    end
  end

  def ready_for_duly_authorized_representative?
    duly_authorized_representative_signature_print.present? && duly_authorized_representative_email.present?
  end

  def send_duly_authorized_representative_signature_request_in_background
    update duly_authorized_representative_emailed_at: Time.zone.now
    fork_process(:send_duly_authorized_representative_signature_request)
  end

  def send_duly_authorized_representative_signature_request
    DataRequestMailer.duly_authorized_representative_signature_request(self).deliver_now if EMAILS_ENABLED
  end

  def send_duly_authorized_representative_signature_submitted_in_background
    fork_process(:send_duly_authorized_representative_signature_submitted)
  end

  def send_duly_authorized_representative_signature_submitted
    DataRequestMailer.duly_authorized_representative_signature_submitted(self).deliver_now if EMAILS_ENABLED
  end

  def duly_authorized_representative_signed?
    duly_authorized_representative_signed_at.present?
  end

  def coverage(final_legal_document_page)
    response_count = 0
    variable_count = 0
    final_legal_document_page.variables.where(required: true).each do |variable|
      variable_count += 1
      agreement_variable = agreement_variables.find_by(final_legal_document_variable_id: variable.id)
      if variable.variable_type == "checkbox" && agreement_variable&.value == "1"
        response_count += 1
      elsif variable.variable_type != "checkbox" && agreement_variable&.value.present?
        response_count += 1
      end
    end
    [response_count, variable_count]
  end

  def complete?
    attestation_complete? && pages_complete? && datasets.count.positive?
  end

  def incomplete?
    !complete?
  end
end
