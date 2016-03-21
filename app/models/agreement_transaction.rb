# frozen_string_literal: true

class AgreementTransaction < ApplicationRecord

  TRANSACTION_TYPE = ['agreement_create', 'agreement_update', 'public_agreement_update', 'agreement_rollback']

  # Model Validation
  validates_presence_of :agreement_id, :transaction_type

  # Model Relationships
  belongs_to :agreement
  belongs_to :user
  has_many :agreement_transaction_audits, -> { order :id }

  # Model Methods

  def self.save_agreement!(agreement, params, current_user, remote_ip, transaction_type)
    original_dataset_ids = agreement.dataset_ids.sort

    save_result = case transaction_type when 'agreement_create'
      agreement.save
    else
      agreement.update(params)
    end

    ignore_attributes = %w(created_at updated_at current_step duly_authorized_representative_token signature duly_authorized_representative_signature reviewer_signature printed_file dua executed_dua deleted)

    original_attributes = agreement.previous_changes.collect{|k,v| [k,v[0]]}.reject{|k,v| ignore_attributes.include?(k.to_s)}

    dataset_ids = agreement.dataset_ids.sort

    original_attributes << ['dataset_ids', original_dataset_ids] if original_dataset_ids != dataset_ids

    if save_result and original_attributes.count > 0
      agreement_transaction = self.create( transaction_type: transaction_type, agreement_id: agreement.id, user_id: (current_user ? current_user.id : nil), remote_ip: remote_ip )
      agreement_transaction.generate_audits!(original_attributes)
    end

    save_result
  end

  def generate_audits!(original_attributes)
    original_attributes.each do |trackable_attribute, old_value|
      value_before = (old_value == nil ? nil : old_value.to_s)
      value_after = (self.agreement.send(trackable_attribute) == nil ? nil : self.agreement.send(trackable_attribute).to_s)
      if value_before != value_after
        self.agreement_transaction_audits.create( agreement_attribute_name: trackable_attribute.to_s, value_before: value_before, value_after: value_after, agreement_id: self.agreement_id, user_id: self.user_id )
      end
    end
  end

end
