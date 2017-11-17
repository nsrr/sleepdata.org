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

  # TODO: Update data request export to use new agreement_variables.
  # GET /agreements/export
  def export
    @csv_string = CSV.generate do |csv|
      csv << [
        "Status",
        "Last Submitted Date",
        "Approval Date",
        "Expiration Date",
        "Approved By",
        "Rejected By",
        "Data Request",
        "Data User",
        "Data User Type",
        "Individual Institution Name",
        "Individual Name",
        "Individual Title",
        "Individual Telephone",
        "Individual Fax",
        "Individual Email",
        "Individual Address",
        "Organization Business Name",
        "Organization Contact Name",
        "Organization Contact Title",
        "Organization Contact Telephone",
        "Organization Contact Fax",
        "Organization Contact Email",
        "Organization Address",
        "Title of Project",
        "Specific Purpose",
        "Datasets",
        "Posting Permission",
        "Unauthorized to Sign",
        "Signature Print",
        "Signature Date",
        "Duly Authorized Representative Signature Print",
        "Duly Authorized Representative Signature Date",
        "IRB Evidence Type",
        "Intended Use of Data",
        "Data Secured Location",
        "Secured Device",
        "Human Subjects Protections Trained"
      ] + Tag.review_tags.order(:name).pluck(:name)

      DataRequest.current.includes(agreement_tags: :tag).each do |a|
        row = [
          a.status,
          a.last_submitted_at,
          a.approval_date,
          a.expiration_date,
          a.reviews.where(approved: true).collect{|r| r.user.initials}.join(","),
          a.reviews.where(approved: false).collect{|r| r.user.initials}.join(","),
          a.name,
          a.data_user,
          a.data_user_type,
          a.individual_institution_name,
          a.user.name,
          a.individual_title,
          a.individual_telephone,
          a.individual_fax,
          a.user.email,
          a.individual_address,
          a.organization_business_name,
          a.organization_contact_name,
          a.organization_contact_title,
          a.organization_contact_telephone,
          a.organization_contact_fax,
          a.organization_contact_email,
          a.organization_address,
          a.title_of_project,
          a.specific_purpose,
          a.datasets.pluck(:name).sort.join(", "),
          a.posting_permission,
          a.unauthorized_to_sign,
          a.signature_print,
          a.signature_date,
          a.duly_authorized_representative_signature_print,
          a.duly_authorized_representative_signature_date,
          a.irb_evidence_type,
          a.intended_use_of_data,
          a.data_secured_location,
          a.secured_device,
          a.human_subjects_protections_trained
        ]
        Tag.review_tags.order(:name).each do |tag|
          row << a.tags.collect(&:id).include?(tag.id)
        end
        csv << row
      end
    end

    send_data(
      @csv_string,
      type: "text/csv; charset=iso-8859-1; header=present",
      disposition: "attachment; filename=\"data-requests-#{Time.zone.now.strftime("%Y%m%d-%Ih%M%p")}.csv\""
    )
  end

  # GET /agreements/1
  def show
    redirect_to reviews_path
  end

  # PATCH /agreements/1
  # PATCH /agreements/1.js
  def update
    original_status = @data_request.status
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
