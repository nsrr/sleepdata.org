# frozen_string_literal: true

namespace :agreements do

  desc 'Update existing agreements to new format'
  task clean: :environment do
    # Clean up step 4 signature for those who have signed
    Agreement.where.not(signature: ["",nil]).where(unauthorized_to_sign: true).update_all unauthorized_to_sign: false
  end

  desc 'Create initial transactions for existing agreements'
  task create_transactions: :environment do
    puts "Agreement Transactions: #{AgreementTransaction.count}"
    puts "Agreement Transaction Audits: #{AgreementTransactionAudit.count}"
    # ActiveRecord::Base.connection.execute("TRUNCATE agreement_transactions RESTART IDENTITY")
    # ActiveRecord::Base.connection.execute("TRUNCATE agreement_transaction_audits RESTART IDENTITY")
    # puts "Agreement Transactions: #{AgreementTransaction.count}"
    # puts "Agreement Transaction Audits: #{SheetTransactionAudit.count}"


    Agreement.order(id: :desc).each do |agreement|
      if agreement.agreement_transactions.count > 0
        puts "Skipping #{agreement.name} agreements/#{agreement.id}"
        next
      end

      ActiveRecord::Base.transaction do
        current_time = nil
        transaction_type = 'agreement_create'
        agreement_transaction = AgreementTransaction.create( transaction_type: transaction_type, agreement_id: agreement.id, user_id: agreement.user_id, remote_ip: (agreement.user ? agreement.user.current_sign_in_ip : nil) )

        ignored_attributes = %w(created_at updated_at current_step duly_authorized_representative_token signature duly_authorized_representative_signature reviewer_signature printed_file dua executed_dua has_read_step5 history deleted)

        agreement.attributes.reject{|k,v| ignored_attributes.include?(k.to_s)}.each do |k,v|
          value_before = nil
          value_after = nil
          if v.is_a?(Array)
            value_before = v[0]
            value_after = v[1]
          else
            value_after = v
          end
          if ['evidence_of_irb_review', 'has_read_step3', 'secured_device', 'human_subjects_protections_trained', 'unauthorized_to_sign'].include?(k.to_s)
            value_before = (value_before.to_s == '1' ? 'true' : 'false')
            value_after = (value_after.to_s == '1' ? 'true' : 'false')
          end
          if value_before != value_after
            agreement_transaction.agreement_transaction_audits.create( agreement_attribute_name: k.to_s, value_before: value_before, value_after: value_after, agreement_id: agreement_transaction.agreement_id, user_id: agreement_transaction.user_id )
          end
        end

      end

      puts "Created Transaction for #{agreement.name} agreements/#{agreement.id}"
    end
  end

end
