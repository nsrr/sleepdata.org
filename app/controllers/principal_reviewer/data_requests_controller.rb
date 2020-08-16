# frozen_string_literal: true

# Allows principal reviewers to approve and reject data requests as well as add
# and remove datasets.
class PrincipalReviewer::DataRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_principal_reviewable_data_request_or_redirect, only: [:review] # , only: [:destroy]

  layout "layouts/full_page_sidebar"

  # PATCH /data-requests/1/review
  # PATCH /data-requests/1/review.js
  def review
    original_status = @data_request.status
    original_dataset_ids = @data_request.dataset_ids.sort

    if AgreementTransaction.save_agreement!(@data_request, current_user, request.remote_ip, "agreement_update", data_request_params: data_request_params)
      if original_status != "approved" && @data_request.status == "approved"
        @data_request.save_signature!(:reviewer_signature_file, params[:data_uri]) if params[:data_uri].present?
        @data_request.daua_approved_email(current_user)
      elsif original_status != "resubmit" && @data_request.status == "resubmit"
        @data_request.sent_back_for_resubmission_email(current_user)
      elsif original_status != "closed" && @data_request.status == "closed"
        @data_request.close_daua!(current_user)
      end
      @data_request.compute_datasets_added_removed!(original_dataset_ids, current_user)
      respond_to do |format|
        format.html { redirect_to review_path(@data_request, anchor: @data_request.agreement_events.last ? "c#{@data_request.agreement_events.last.number}" : nil), notice: "Data request was successfully updated." }
        format.js { render "agreement_events/index" }
      end
    else
      respond_to do |format|
        format.html { render "reviews/show" }
        format.js { render :edit }
      end
    end
  end

  # # DELETE /agreements/1
  # def destroy
  #   @data_request.destroy
  #   redirect_to reviews_path
  # end

  private

  def find_principal_reviewable_data_request_or_redirect
    @data_request = current_user.principal_reviewable_data_requests.find_by(id: params[:id])
    empty_response_or_root_path(reviews_path) unless @data_request
  end

  def data_request_params
    params[:data_request] ||= {}
    parse_date_if_key_present(:data_request, :approval_date)
    parse_date_if_key_present(:data_request, :expiration_date)
    params[:data_request][:dataset_ids] = @data_request.dataset_ids if params[:data_request].key?(:dataset_ids) && params[:data_request][:dataset_ids] == ["0"]
    params.require(:data_request).permit(
      :status, :comments, :approval_date, :expiration_date,
      dataset_ids: []
    )
  end
end
