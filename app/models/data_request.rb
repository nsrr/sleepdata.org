# frozen_string_literal: true

# Allows users to request access to one or more datasets.
class DataRequest < Agreement
  # Constants
  ORDERS = {
    "expires desc" => "agreements.expiration_date desc",
    "expires" => "agreements.expiration_date",
    "submitted desc" => "agreements.last_submitted_at desc nulls last",
    "submitted" => "agreements.last_submitted_at",
    "status desc" => "agreements.status desc",
    "status" => "agreements.status",
    "id desc" => "agreements.id desc",
    "id" => "agreements.id"
  }
  DEFAULT_ORDER = "agreements.last_submitted_at desc nulls last"

  STATUS = %w(started submitted approved resubmit expired closed).collect { |i| [i, i] }

  # Relationships
  has_many :supporting_documents

  def ignored_transaction_attributes
    %w(
      created_at
      updated_at
      current_step
      duly_authorized_representative_token
      printed_file
      deleted
    )
  end

  def filtered_changes
    all_changes = (new_record? ? changes : saved_changes)
    all_changes.reject { |k, _v| ignored_transaction_attributes.include?(k.to_s) }
  end

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
    when "checkbox"
      attested_at.present?
    else
      true
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
      next if agreement_variable&.resubmission_required?
      if variable.variable_type == "checkbox" && agreement_variable&.value == "1"
        response_count += 1
      elsif variable.variable_type != "checkbox" && agreement_variable&.value.present?
        response_count += 1
      end
    end
    final_legal_document_page.variables.where(required: false).each do |variable|
      agreement_variable = agreement_variables.find_by(final_legal_document_variable_id: variable.id)
      variable_count += 1 if agreement_variable&.resubmission_required?
    end
    [response_count, variable_count]
  end

  def complete?
    attestation_complete? && pages_complete? && datasets.count.positive?
  end

  def incomplete?
    !complete?
  end

  def progress
    count = 0
    total = 0
    final_legal_document.final_legal_document_pages.each do |page|
      total += 1
      count += 1 if page_complete?(page)
    end
    if attestation_required?
      total += 1
      count += 1 if attestation_complete?
    end
    total += 1 if status == "started" || status == "resubmit"
    return 100 if total.zero?
    count * 100.0 / total
  end

  def render_variable_latex(final_legal_document_page, variable_id)
    variable = final_legal_document_page.final_legal_document.legal_document_variables.find_by(id: variable_id)
    agreement_variable = agreement_variables.find_by(final_legal_document_variable: variable)
    value = (agreement_variable&.value || "")
    if variable.variable_type == "radio"
      string = "\n**#{variable.display_name_label}**"
      variable.options.each do |option|
        string += \
          if value == option.value
            "\n==**XXYESXX** #{option.display_name}=="
          else
            "\n**XXNOXX** #{option.display_name}"
          end
      end
      string
    elsif variable.variable_type == "checkbox"
      if value == "1"
        "\n**#{variable.display_name_label}**\n==**XXYESXX** #{variable.description}=="
      else
        "\n**#{variable.display_name_label}**\n**XXNOXX** #{variable.description}"
      end
    else
      "\n**#{variable.display_name_label}**\n==#{value}=="
    end
  end

  def render_variable_inline_latex(final_legal_document_page, variable_id)
    agreement_variable = agreement_variables.find_by(final_legal_document_variable_id: variable_id)
    value = (agreement_variable ? agreement_variable.value : "")
    "==#{value}=="
  end

  def convert_to(new_final_legal_document, current_user, remote_ip)
    hash = {
      final_legal_document: new_final_legal_document,
      attested_at: nil,
      remove_signature_file: true,
      signature_print: nil,
      signature_date: nil,
      duly_authorized_representative_email: nil,
      duly_authorized_representative_emailed_at: nil,
      duly_authorized_representative_signed_at: nil,
      remove_duly_authorized_representative_signature_file: true,
      duly_authorized_representative_signature_print: nil,
      duly_authorized_representative_signature_date: nil
    }
    AgreementTransaction.save_agreement!(self, current_user, remote_ip, "agreement_update", data_request_params: hash)
  end

  # Removes variables that may exist on alternate final legal document.
  def cleanup_variables!
    agreement_variables
      .joins(:final_legal_document_variable)
      .merge(FinalLegalDocumentVariable.where.not(final_legal_document: final_legal_document))
      .destroy_all
  end

  def representative_designated?
    duly_authorized_representative_email.present? || duly_authorized_representative_signature_print.present?
  end

  def has_voted?(current_user)
    data_request_reviews.where(user: current_user).where(approved: [true, false]).present?
  end

  def compute_datasets_added_removed!(original_dataset_ids, current_user)
    current_dataset_ids = dataset_ids.sort
    return if original_dataset_ids == current_dataset_ids

    added_removed_dataset_ids = []
    (original_dataset_ids | current_dataset_ids).sort.each do |dataset_id|
      if original_dataset_ids.include?(dataset_id) && !current_dataset_ids.include?(dataset_id)
        added_removed_dataset_ids << [dataset_id, false]
      elsif !original_dataset_ids.include?(dataset_id) && current_dataset_ids.include?(dataset_id)
        added_removed_dataset_ids << [dataset_id, true]
      end
    end

    if added_removed_dataset_ids.present?
      agreement_event = agreement_events.create(event_type: "datasets_updated", user: current_user, event_at: Time.zone.now)
      added_removed_dataset_ids.each do |dataset_id, added|
        agreement_event.agreement_event_datasets.create(dataset_id: dataset_id, added: added)
      end
    end
  end

  def reset_signature_fields!(current_user)
    hash = {
      attested_at: nil,
      remove_signature_file: true,
      signature_print: nil,
      signature_date: nil,
      duly_authorized_representative_email: nil,
      duly_authorized_representative_emailed_at: nil,
      duly_authorized_representative_signed_at: nil,
      remove_duly_authorized_representative_signature_file: true,
      duly_authorized_representative_signature_print: nil,
      duly_authorized_representative_signature_date: nil
    }
    AgreementTransaction.save_agreement!(self, current_user, current_user.current_sign_in_ip, "agreement_update", data_request_params: hash)
  end
end
