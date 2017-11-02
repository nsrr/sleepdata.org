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

  def self.save_agreement!(data_request, params, current_user, remote_ip, transaction_type)
    original_dataset_ids = data_request.dataset_ids.sort
    save_result = \
      case transaction_type
      when "agreement_create"
        data_request.save
      else
        data_request.update(params)
      end

    original_attributes = \
      data_request.previous_changes
                  .collect { |k, v| [k, v[0]] }
                  .reject { |k, _v| data_request.ignored_transaction_attributes.include?(k.to_s) }

    dataset_ids = data_request.dataset_ids.sort
    original_attributes << ["dataset_ids", original_dataset_ids] if original_dataset_ids != dataset_ids

    if save_result && original_attributes.count.positive?
      agreement_transaction = create(
        transaction_type: transaction_type,
        agreement_id: data_request.id,
        user: current_user,
        remote_ip: remote_ip
      )
      agreement_transaction.generate_audits!(original_attributes)
    end
    save_result
  end

  def generate_audits!(original_attributes)
    original_attributes.each do |trackable_attribute, old_value|
      value_before = (old_value.nil? ? nil : old_value.to_s)
      value_after = \
        if trackable_attribute == "irb"
          data_request.irb.file.present? ? data_request.irb.file.filename : nil
        else
          data_request.send(trackable_attribute).nil? ? nil : data_request.send(trackable_attribute).to_s
        end
      next if value_before == value_after
      agreement_transaction_audits.create(
        agreement_attribute_name: trackable_attribute.to_s,
        value_before: value_before,
        value_after: value_after,
        agreement_id: agreement_id,
        user_id: user_id
      )
    end
  end
end
