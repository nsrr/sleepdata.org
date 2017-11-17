# frozen_string_literal: true

class AgreementTransaction < ApplicationRecord
  TRANSACTION_TYPE = [
    "agreement_create",
    "agreement_update",
    "public_agreement_update",
    "agreement_rollback"
  ]

  # Validations
  validates :transaction_type, presence: true

  # Relationships
  belongs_to :agreement
  belongs_to :data_request, class_name: "DataRequest", foreign_key: "agreement_id"
  belongs_to :user, optional: true
  has_many :agreement_transaction_audits, -> { order :id }

  # Methods

  def self.save_agreement!(data_request, current_user, remote_ip, transaction_type, data_request_params: {}, variable_changes: [])
    (save_result, filtered_changes) = \
      save_or_update_data_request!(data_request, data_request_params, transaction_type)
    if save_result
      generate_audits!(data_request, transaction_type, remote_ip, current_user, filtered_changes)
      update_variables!(data_request, transaction_type, remote_ip, current_user, variable_changes)
    end
    save_result
  end

  def self.save_or_update_data_request!(data_request, data_request_params, transaction_type)
    original_dataset_ids = []
    filtered_changes = data_request.filtered_changes
    case transaction_type
    when "agreement_create"
      filtered_changes = data_request.filtered_changes # Before save for "changes"
      filtered_changes["status"] ||= [nil, "started"]
      save_result = data_request.save
    else
      original_dataset_ids = data_request.dataset_ids.sort
      save_result = data_request.update(data_request_params)
      filtered_changes = data_request.filtered_changes # After save for "saved_changes"
    end
    dataset_ids = data_request.dataset_ids.sort
    filtered_changes["dataset_ids"] = [original_dataset_ids, dataset_ids]
    [save_result, filtered_changes]
  end

  def self.generate_audits!(data_request, transaction_type, remote_ip, current_user, filtered_changes)
    data_request_transaction = nil
    filtered_changes.each do |key, values|
      value_before = (values.first.nil? ? nil : values.first.to_s)
      value_after = (values.last.nil? ? nil : values.last.to_s)
      next if value_before == value_after
      data_request_transaction ||= create_data_request_transaction(data_request, transaction_type, remote_ip, current_user)
      data_request_transaction.agreement_transaction_audits.create(
        agreement_attribute_name: key,
        value_before: value_before,
        value_after: value_after,
        agreement: data_request,
        user: current_user
      )
    end
  end

  def self.update_variables!(data_request, transaction_type, remote_ip, current_user, variable_changes)
    data_request_transaction = nil
    variable_changes.each do |variable, new_value|
      agreement_variable = data_request.agreement_variables.where(final_legal_document_variable_id: variable.id).first_or_create
      old_value = agreement_variable.value
      agreement_variable.update(value: new_value)
      value_before = (old_value.nil? ? nil : old_value.to_s)
      value_after = (new_value.nil? ? nil : new_value.to_s)
      next if value_before == value_after
      data_request_transaction ||= create_data_request_transaction(data_request, transaction_type, remote_ip, current_user)
      data_request_transaction.agreement_transaction_audits.create(
        final_legal_document_variable: variable,
        value_before: value_before,
        value_after: value_after,
        agreement: data_request,
        user: current_user
      )
    end
  end

  def self.create_data_request_transaction(data_request, transaction_type, remote_ip, current_user)
    data_request_transaction = create(
      agreement: data_request,
      transaction_type: transaction_type,
      remote_ip: remote_ip,
      user: current_user
    )
  end
end
