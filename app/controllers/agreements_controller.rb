# frozen_string_literal: true

# Allows reviewers to view and update data requests.
class AgreementsController < ApplicationController
  before_action :authenticate_user!
  # TODO: Change to only be for organization owners (or remove controller).
  before_action :check_system_admin
  before_action :find_data_request_or_redirect, only: [:update, :destroy]

  # GET /agreements
  def index
    redirect_to reviews_path
  end

  # GET /agreements/export
  def export
    organization = current_user.organizations.first
    @export = current_user.exports.create(
      name: "#{organization.slug.upcase} Data Requests #{Time.zone.now.strftime("%b %-d, %Y")}",
      organization: organization
    )
    @export.generate_export_in_background!
    redirect_to @export, notice: "Export started."
  end

  # GET /agreements/1
  def show
    redirect_to reviews_path
  end

  # PATCH /agreements/1
  # PATCH /agreements/1.js
  def update
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
      elsif original_status != "expired" && @data_request.status == "expired"
        @data_request.expire_daua!(current_user)
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

  # DELETE /agreements/1
  def destroy
    @data_request.destroy
    redirect_to agreements_path
  end

  private

  def find_data_request_or_redirect
    @data_request = DataRequest.current.find_by(id: params[:id])
    redirect_without_data_request
  end

  def redirect_without_data_request
    empty_response_or_root_path(current_user.system_admin? ? agreements_path : reviews_path) unless @data_request
  end

  def data_request_params
    params[:data_request] ||= {}
    parse_date_if_key_present(:data_request, :approval_date)
    parse_date_if_key_present(:data_request, :expiration_date)
    params[:data_request][:dataset_ids] = @data_request.dataset_ids if params[:data_request].key?(:dataset_ids) && params[:data_request][:dataset_ids] == ["0"]
    # TODO: Add data_uri or reviewer_signature_file_data_uri?
    params.require(:data_request).permit(
      :status, :comments, :approval_date, :expiration_date,
      dataset_ids: []
    )
  end
end
