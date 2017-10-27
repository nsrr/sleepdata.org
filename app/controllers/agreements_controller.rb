# frozen_string_literal: true

# Allows reviewers to view and update data requests.
class AgreementsController < ApplicationController
  before_action :authenticate_user!
  # TODO: Change to only be for reviewers.
  before_action :check_system_admin, except: [
    :renew, :daua, :dua, :create_step, :step, :update_step, :proof,
    :final_submission, :destroy_submission, :download_irb, :print, :complete,
    :new_step, :irb_assistance
  ]
  # before_action :find_viewable_submission_or_redirect, only: [:renew, :complete]
  # before_action :find_editable_submission_or_redirect, only: [:step, :update_step, :proof, :final_submission]
  # before_action :find_deletable_submission_or_redirect, only: [:destroy_submission]
  # before_action :set_step,                       only: [:create_step, :step, :update_step]
  before_action :set_downloadable_irb_data_request, only: [:download_irb, :print]
  before_action :set_data_request,                  only: [:destroy, :download, :update]
  before_action :redirect_without_data_request,     only: [:destroy, :download, :update, :download_irb, :print]

  # TODO: Remove deprecated step wizard
  # # GET /agreements/1/step
  # def step
  #   if @step && @step > 0 && @step < 6
  #     render "agreements/wizard/step#{@step}"
  #   elsif @step == 6
  #     render :proof
  #   else
  #     redirect_to step_agreement_path(@agreement, step: 1)
  #   end
  # end

  # # GET /agreements/new_step
  # def new_step
  #   @step = 1
  #   @agreement = current_user.agreements.new(data_user: current_user.name)
  #   render "agreements/wizard/step#{@step}"
  # end

  # # GET /agreements/1/renew
  # def renew
  #   @step = 1
  #   @agreement = current_user.agreements.create(@agreement.copyable_attributes)
  #   render "agreements/wizard/step#{@step}"
  # end

  # # POST /agreements
  # def create_step
  #   @agreement = current_user.agreements.new(step_params)
  #   if AgreementTransaction.save_agreement!(@agreement, step_params, current_user, request.remote_ip, "agreement_create")
  #     if @agreement.draft_mode?
  #       redirect_to submissions_path
  #     else
  #       redirect_to step_agreement_path(@agreement, step: 2)
  #     end
  #   else
  #     render "agreements/wizard/step#{@step}"
  #   end
  # end

  # # PATCH /agreements/1/update_step
  # def update_step
  #   if AgreementTransaction.save_agreement!(@agreement, step_params, current_user, request.remote_ip, "agreement_update")
  #     if @agreement.draft_mode?
  #       redirect_to submissions_path
  #     elsif @agreement.fully_filled_out? || @agreement.current_step == 5
  #       redirect_to proof_agreement_path(@agreement)
  #     else
  #       redirect_to step_agreement_path(@agreement, step: @agreement.current_step + 1)
  #     end
  #   elsif @step
  #     render "agreements/wizard/step#{@step}"
  #   else
  #     redirect_to submissions_path
  #   end
  # end

  # # GET /agreements/1/proof
  # def proof
  #   @step = 6
  # end

  # # PATCH /agreements/1/final_submission
  # def final_submission
  #   current_time = Time.zone.now
  #   if @agreement.status == "resubmit"
  #     hash = { status: "submitted", resubmitted_at: current_time, last_submitted_at: current_time }
  #     event_type = "user_resubmitted"
  #   else
  #     hash = { status: "submitted", submitted_at: current_time, last_submitted_at: current_time }
  #     event_type = "user_submitted"
  #   end

  #   if !@agreement.fully_filled_out?
  #     render "proof"
  #   elsif AgreementTransaction.save_agreement!(@agreement, hash, current_user, request.remote_ip, "agreement_update")
  #     @agreement.agreement_events.create event_type: event_type, user_id: current_user.id, event_at: current_time
  #     @agreement.daua_submitted_in_background
  #     redirect_to complete_agreement_path(@agreement)
  #   else
  #     redirect_to submissions_path
  #   end
  # end

  # GET /agreements
  def index
    redirect_to reviews_path
  end

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
    if AgreementTransaction.save_agreement!(@data_request, data_request_params, current_user, request.remote_ip, "agreement_update")
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
        format.html { redirect_to review_path(@data_request) + "#c#{@data_request.agreement_events.last.number}", notice: "Data request was successfully updated." }
        format.js { render "agreement_events/index" }
      end
    else
      render "reviews/show"
    end
  end

  # GET /agreements/1/download_irb
  def download_irb
    send_file_if_present @data_request.irb, disposition: "inline"
  end

  # GET /agreements/1/print
  def print
    @data_request.generate_printed_pdf!
    if @data_request.printed_file.present?
      send_file @data_request.printed_file.path, filename: "#{@data_request.user.last_name.gsub(/[^a-zA-Z\p{L}]/, '')}-#{@data_request.user.first_name.gsub(/[^a-zA-Z\p{L}]/, '')}-#{@data_request.agreement_number}-data-request-#{(@data_request.submitted_at || @data_request.created_at).strftime("%Y-%m-%d")}.pdf", type: "application/pdf", disposition: "inline"
    else
      render layout: false
    end
  end

  # GET /agreements/1/download
  def download
    send_file_if_present(
      params[:executed] == "1" ? @data_request.executed_dua : @data_request.dua,
      disposition: "inline"
    )
  end

  # DELETE /agreements/1/destroy_submission
  def destroy_submission
    @data_request.destroy
    redirect_to submissions_path
  end

  # DELETE /agreements/1
  def destroy
    @data_request.destroy

    respond_to do |format|
      format.html { redirect_to agreements_path }
      format.json { head :no_content }
    end
  end

  private

  def set_data_request
    @data_request = DataRequest.current.find_by(id: params[:id])
  end

  def set_downloadable_irb_data_request
    @data_request = current_user.all_data_requests.find_by(id: params[:id])
  end

  # def find_viewable_submission_or_redirect
  #   @agreement = current_user.agreements.find_by_id params[:id]
  #   redirect_without_submission
  # end

  # def find_editable_submission_or_redirect
  #   @agreement = current_user.agreements.submittable.find_by_id params[:id]
  #   redirect_without_submission
  # end

  # def find_deletable_submission_or_redirect
  #   @agreement = current_user.agreements.deletable.find_by_id params[:id]
  #   redirect_without_submission
  # end

  # def redirect_without_submission
  #   empty_response_or_root_path(submissions_path) unless @agreement
  # end

  def redirect_without_data_request
    empty_response_or_root_path(current_user && current_user.system_admin? ? agreements_path : submissions_path) unless @data_request
  end

  def data_request_params
    params[:data_request] ||= {}
    parse_date_if_key_present(:data_request, :approval_date)
    parse_date_if_key_present(:data_request, :expiration_date)
    # TODO: Add data_uri or reviewer_signature_file_data_uri?
    params.require(:data_request).permit(
      :status, :comments, :approval_date, :expiration_date,
      dataset_ids: []
    )
  end

  # def daua_submission_params
  #   params[:agreement] ||= { dua: "", remove_dua: "1" }
  #   params.require(:agreement).permit(:dua, :remove_dua)
  # end

  # def set_step
  #   @step = params[:step].to_i if params[:step].to_i > 0 && params[:step].to_i < 9
  # end

  # def step_params
  #   params[:agreement] ||= {}
  #   params[:agreement][:signature_date] = parse_date(params[:agreement][:signature_date]) if params[:agreement].key?(:signature_date)
  #   if params[:agreement].key?(:dataset_ids)
  #     params[:agreement][:dataset_ids] = Dataset.released.where(id: params[:agreement][:dataset_ids]).pluck(:id)
  #   end
  #   params.require(:agreement).permit(
  #     :current_step, :draft_mode,
  #     # Step One
  #       :data_user, :data_user_type,
  #     #   Individual
  #       :individual_institution_name, :individual_title, :individual_telephone, :individual_address,
  #     #   Organization
  #       :organization_business_name, :organization_contact_name, :organization_contact_title, :organization_contact_telephone, :organization_contact_email, :organization_address,
  #     # Step Two
  #       :specific_purpose, { dataset_ids: [] },
  #     # Step Three
  #       :has_read_step3,
  #     # Step Four
  #       :posting_permission,
  #     # Step Five
  #       :has_read_step5,
  #     # Step Six
  #       :unauthorized_to_sign,
  #       # Data User Authorized to Sign
  #       :signature, :signature_print, :signature_date,
  #       # Duly Authorized Representative to Sign
  #       :duly_authorized_representative_signature_print,
  #     # Step Seven
  #       :irb_evidence_type, :irb,
  #     # Step Eight
  #       :title_of_project, :intended_use_of_data, :data_secured_location, :secured_device, :human_subjects_protections_trained
  #   )
  # end
end
