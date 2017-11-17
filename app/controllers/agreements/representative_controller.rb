# frozen_string_literal: true

# Allows duly authorized representatives to review and sign data access and use
# agreements on behalf of the data user.
class Agreements::RepresentativeController < ApplicationController
  prepend_before_action { request.env["devise.skip_timeout"] = true }
  skip_before_action :verify_authenticity_token
  before_action :find_data_request_or_redirect, only: [
    :signature_requested, :submit_signature
  ]

  # GET /representative/1-abcd/signature-requested
  def signature_requested
    @step = 4
  end

  # POST /representative/1-abcd/submit-signature
  def submit_signature
    if AgreementTransaction.save_agreement!(@data_request, current_user, request.remote_ip, "public_agreement_update", data_request_params: duly_authorized_params)
      @data_request.save_signature!(:duly_authorized_representative_signature_file, params[:data_uri])
      @data_request.send_duly_authorized_representative_signature_submitted_in_background
      redirect_to representative_signature_submitted_path
    else
      render :signature_requested
    end
  end

  # # GET /representative/signature-submitted
  # def signature_submitted
  # end

  private

  def authenticate_data_request_from_token!
    data_request_id = params[:representative_token].to_s.split("-").first
    auth_token = params[:representative_token].to_s.gsub(/^#{data_request_id}-/, "")
    data_request = data_request_id && DataRequest.current.submittable.find_by(id: data_request_id)
    # Devise.secure_compare is used to mitigate timing attacks.
    return unless data_request && Devise.secure_compare(data_request.duly_authorized_representative_token, auth_token)
    @data_request = data_request
  end

  def find_data_request_or_redirect
    authenticate_data_request_from_token!
    redirect_to root_path, alert: "Data request has been locked." unless @data_request
  end

  def duly_authorized_params
    time = Time.zone.now
    params[:data_request] ||= { blank: "1" }
    params[:data_request][:representative] = "1"
    params[:data_request][:duly_authorized_representative_signed_at] = time
    params[:data_request][:duly_authorized_representative_signature_date] = time
    params.require(:data_request).permit(
      :duly_authorized_representative_signature_print,
      :duly_authorized_representative_title,
      :duly_authorized_representative_signed_at,
      :duly_authorized_representative_signature_date,
      :representative
    )
  end
end
