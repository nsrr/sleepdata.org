# frozen_string_literal: true

# Allows duly authorized representatives to review and sign data access and use
# agreements on behalf of the data user.
class Agreements::RepresentativeController < ApplicationController
  prepend_before_action { request.env['devise.skip_timeout'] = true }
  skip_before_action :verify_authenticity_token
  before_action :find_agreement_or_redirect, only: [
    :signature_requested, :submit_signature
  ]

  # GET /representative/1-abcd/signature-requested
  def signature_requested
    @step = 4
  end

  # POST /representative/1-abcd/submit-signature
  def submit_signature
    @step = 4
    if AgreementTransaction.save_agreement!(@agreement, duly_authorized_params,
                                            current_user, request.remote_ip, 'public_agreement_update')
      @agreement.update_column :current_step, 4
      @agreement.send_daua_signed_email_in_background
      redirect_to representative_signature_submitted_path
    else
      render :signature_requested
    end
  end

  # GET /representative/signature-submitted
  def signature_submitted
  end

  private

  def authenticate_agreement_from_token!
    agreement_id = params[:representative_token].to_s.split('-').first
    auth_token = params[:representative_token].to_s.gsub(/^#{agreement_id}-/, '')
    agreement = agreement_id && Agreement.current.submittable.find_by_id(agreement_id)
    # Devise.secure_compare is used to mitigate timing attacks.
    if agreement && Devise.secure_compare(agreement.duly_authorized_representative_token, auth_token)
      @agreement = agreement
    end
  end

  def find_agreement_or_redirect
    authenticate_agreement_from_token!
    redirect_to root_path, alert: 'Agreement has been locked.' unless @agreement
  end

  def duly_authorized_params
    params[:agreement] ||= { blank: '1' }
    parse_date_if_key_present(:agreement, :duly_authorized_representative_signature_date)
    params[:agreement][:unauthorized_to_sign] = true
    params.require(:agreement).permit(
      :current_step, :duly_authorized_representative_signature_print,
      :duly_authorized_representative_signature,
      :duly_authorized_representative_signature_date,
      :duly_authorized_representative_title,
      :unauthorized_to_sign
    )
  end
end
