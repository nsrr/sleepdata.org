# frozen_string_literal: true

# Steps users through requesting dataset access.
class DataRequestsController < ApplicationController
  before_action :authenticate_user!, except: [:start, :create, :join, :login]
  before_action :find_viewable_dataset_or_redirect, only: [
    :start, :create, :join, :login
  ]
  before_action :find_data_request_or_redirect, except: [
    :index,
    :start, :create, :join, :login,
    :submitted, :print, :show,
    :resubmit, :resume, :datasets, :update_datasets,
    :destroy
  ]
  before_action :find_submitted_data_request_or_redirect, only: [:submitted]
  before_action :find_any_data_request_or_redirect, only: [:print, :show]
  before_action :find_submittable_data_request_or_redirect, only: [:resubmit, :resume, :datasets, :update_datasets]
  before_action :find_deletable_data_request_or_redirect, only: [:destroy]

  layout "layouts/full_page"

  # GET /data/requests
  def index
    @data_requests = current_user.data_requests.order(id: :desc).page(params[:page]).per(5)
    render layout: "layouts/full_page_sidebar"
  end

  # GET /data/requests/:dataset_id/start
  def start
    @data_request = @dataset.data_requests.find_by(user: current_user, status: ["resubmit", "started"])
    return unless current_user && @data_request
    redirect_to resume_url(@data_request)
  end

  # POST /data/requests/:dataset_id/start
  def create
    if current_user
      save_data_request_user
    else
      @user = User.new
      render :about_me
    end
  end

  # POST /data/requests/:dataset_id/join
  def join
    if current_user
      save_data_request_user
    else
      @user = User.new(user_params)
      @user.skip_confirmation_notification!
      if @user.save
        save_data_request_user(user: @user, redirect: false)
        @user.send_welcome_email_in_background!(data_request_id: @data_request.id)
        render :data_request_confirm_email
      else
        render :about_me
      end
    end
  end

  # POST /data/requests/:dataset_id/login
  def login
    unless current_user
      user = User.find_by(email: params[:email])
      if user && user.valid_password?(params[:password])
        sign_in(:user, user)
      else
        @user = User.new
        @sign_in_errors = []
        @sign_in = true
        render :about_me
        return
      end
    end
    save_data_request_user
  end

  # POST /data/requests/:data_request_id/convert
  def convert
    current_user.update commercial_type: params[:commercial_type] if %w(commercial noncommercial).include?(params[:commercial_type])
    current_user.update data_user_type: params[:data_user_type] if %w(individual organization).include?(params[:data_user_type])
    # TODO: Make sure data_request is associated to a dataset...
    final_legal_document = @data_request.datasets.first.final_legal_document_for_user(current_user)
    if final_legal_document && @data_request.final_legal_document != final_legal_document
      @data_request.convert_to(final_legal_document, current_user, request.remote_ip)
      flash[:notice] = "Switched to #{params[:commercial_type] || params[:data_user_type]} data request successfully."
    else
      flash[:notice] = "No alternate legal document found."
    end
    redirect_to data_requests_page_path(@data_request, 1)
  end

  # GET /data/requests/:data_request_id/page/:page
  def page
    @final_legal_document_page = @data_request.final_legal_document.final_legal_document_pages.find_by(position: params[:page])
    if @final_legal_document_page
      render layout: "layouts/full_page"
    else
      redirect_to data_requests_start_path(@data_request.datasets.first)
    end
  end

  # POST /data/requests/:data_request_id/page/:page
  def update_page
    variable_changes = []
    @final_legal_document_page = @data_request.final_legal_document.final_legal_document_pages.find_by(position: params[:page])
    @data_request.final_legal_document.final_legal_document_variables.each do |variable|
      variable_changes << [variable, params[variable.name.to_sym]] if params.key?(variable.name)
    end
    AgreementTransaction.save_agreement!(@data_request, current_user, request.remote_ip, "agreement_update", variable_changes: variable_changes)
    @next_page = @data_request.final_legal_document.final_legal_document_pages.find_by(position: @final_legal_document_page.position + 1)

    if params.dig(:data_request, :draft) == "1"
      @data_request.update(current_step: @final_legal_document_page.position)
      redirect_to data_requests_page_path(@data_request, @final_legal_document_page.position), notice: "Data request draft saved successfully."
      return
    else
      @data_request.update(current_step: @next_page.position) if @next_page
    end

    if @next_page
      redirect_to data_requests_page_path(@data_request, @next_page.position)
    elsif %w(signature checkbox).include?(@data_request.final_legal_document.attestation_type)
      redirect_to data_requests_attest_path(@data_request)
    else # attestation_type == "none"
      redirect_to data_requests_proof_path(@data_request)
    end
  end

  # # GET /data/requests/:data_request_id/attest
  # def attest
  # end

  # POST /data/requests/:data_request_id/attest
  def update_attest
    hash = {}
    if @data_request.final_legal_document.attestation_type == "signature" &&
       params[:data_uri].present? && params[:signature_print].present?
      @data_request.save_signature!(:signature_file, params[:data_uri])
      hash[:signature_print] = params[:signature_print].to_s
      hash[:attested_at] =  Time.zone.now
    elsif @data_request.final_legal_document.attestation_type == "checkbox"
      if params[:attest] == "1"
        hash[:attested_at] =  Time.zone.now
      elsif params[:attest] == "0"
        hash[:attested_at] = nil
      end
    end
    AgreementTransaction.save_agreement!(@data_request, current_user, request.remote_ip, "agreement_update", data_request_params: hash)
    if params.dig(:data_request, :draft) == "1"
      redirect_to data_requests_attest_path(@data_request), notice: "Data request draft saved successfully."
    else
      redirect_to [@data_request, :supporting_documents]
    end
  end

  # GET /data/requests/:data_request_id/duly-authorized-representative
  def duly_authorized_representative
    redirect_to data_requests_attest_path(@data_request) unless @data_request.signature_required?
  end

  # POST /data/requests/:data_request_id/duly-authorized-representative
  def update_duly_authorized_representative
    redirect_to data_requests_attest_path(@data_request) unless @data_request.signature_required?
    data_request_params = params.require(:data_request).permit(
      :duly_authorized_representative_signature_print,
      :duly_authorized_representative_email
    )
    AgreementTransaction.save_agreement!(@data_request, current_user, request.remote_ip, "public_agreement_update", data_request_params: data_request_params)
    if @data_request.ready_for_duly_authorized_representative?
      @data_request.send_duly_authorized_representative_signature_request_in_background
      redirect_to data_requests_attest_path(@data_request), notice: "Duly Authorized Representative has been notified by email."
    else
      redirect_to data_requests_duly_authorized_representative_path(@data_request), notice: "Please fill in all fields."
    end
  end

  # GET /data/requests/:data_request_id/addendum
  def addendum
    @final_legal_document_page = @data_request.final_legal_document.final_legal_document_pages.find_by(position: params[:addendum])
    if @final_legal_document_page
      render :page, layout: "layouts/full_page"
    else
      redirect_to data_requests_start_path(@dataset)
    end
  end

  # # GET /data/requests/:data_request_id/proof
  # def proof
  # end

  # # GET /data/requests/:id/datasets
  # def datasets
  # end

  # POST /data/requests/:id/datasets
  def update_datasets
    if clean_dataset_ids.present?
      original_dataset_ids = @data_request.dataset_ids.sort
      AgreementTransaction.save_agreement!(@data_request, current_user, request.remote_ip, "agreement_update", data_request_params: data_request_params)
      @data_request.compute_datasets_added_removed!(original_dataset_ids, current_user) if @data_request.status == "resubmit"
      if params.dig(:data_request, :draft) == "1"
        redirect_to data_requests_proof_path(@data_request), notice: "Data request draft saved successfully."
      else
        redirect_to data_requests_proof_path(@data_request)
      end
    else
      @datasets_empty = true
      render :datasets
    end
  end

  # GET /data/requests/:data_request_id/signature
  def signature
    send_signature(:signature_file)
  end

  # GET /data/requests/:data_request_id/duly_authorized_representative_signature
  def duly_authorized_representative_signature
    send_signature(:duly_authorized_representative_signature_file)
  end

  # GET /data/requests/:data_request_id/reviewer_signature
  def reviewer_signature
    send_signature(:reviewer_signature_file)
  end

  # POST /data/requests/:data_request_id/proof
  def submit
    if params.dig(:data_request, :draft) == "1"
      redirect_to data_requests_proof_path(@data_request), notice: "Data request draft saved successfully."
    elsif @data_request.complete?
      current_time = Time.zone.now
      if @data_request.status == "resubmit"
        hash = { status: "submitted", resubmitted_at: current_time, last_submitted_at: current_time }
        event_type = "user_resubmitted"
      else
        hash = { status: "submitted", submitted_at: current_time, last_submitted_at: current_time }
        event_type = "user_submitted"
      end
      if AgreementTransaction.save_agreement!(@data_request, current_user, request.remote_ip, "agreement_update", data_request_params: hash)
        @data_request.cleanup_variables!
        @data_request.update(current_step: 0)
        @data_request.agreement_events.create(event_type: event_type, user: current_user, event_at: current_time)
        @data_request.daua_submitted_in_background
        redirect_to [:submitted, @data_request]
      else
        render :proof
      end
    else
      redirect_to data_requests_proof_path(@data_request), notice: "Please fill out all required fields."
    end
  end

  # GET /data/requests/:id/submitted
  def submitted
    render layout: "layouts/application"
  end

  # GET /data/requests/:id/print
  def print
    @data_request.generate_printed_pdf!
    if @data_request.printed_file.present?
      send_file @data_request.printed_file.path, filename: "#{@data_request.user.username.gsub(/[^a-zA-Z\p{L}]/, "")}-#{@data_request.agreement_number}-data-request-#{(@data_request.submitted_at || @data_request.created_at).strftime("%Y-%m-%d")}.pdf", type: "application/pdf", disposition: "inline"
    else
      render layout: false
    end
  end

  # GET /data/requests/:id
  def show
    render layout: "layouts/full_page_sidebar"
  end

  # GET /data/requests/:id/resubmit
  def resubmit
    redirect_to resume_url(@data_request)
  end

  # GET /data/requests/:id/resume
  def resume
    redirect_to resume_url(@data_request)
  end

  # DELETE /data/requests/:id
  def destroy
    @data_request.destroy
    redirect_to data_requests_path, notice: "Data request was successfully deleted."
  end

  private

  def find_data_request_or_redirect
    @data_request = current_user.data_requests
                                .submittable
                                .includes(:final_legal_document)
                                .find_by(id: params[:data_request_id])
    empty_response_or_root_path(datasets_path) unless @data_request && @data_request.datasets.count.positive?
  end

  def find_submitted_data_request_or_redirect
    @data_request = current_user.data_requests
                                .where(status: ["submitted", "approved"])
                                .find_by(id: params[:id])
    empty_response_or_root_path(datasets_path) unless @data_request && @data_request.datasets.count.positive?
  end

  def find_any_data_request_or_redirect
    @data_request = current_user.data_requests
                                .includes(:final_legal_document)
                                .find_by(id: params[:id])
    empty_response_or_root_path(datasets_path) unless @data_request && @data_request.datasets.count.positive?
  end

  def find_submittable_data_request_or_redirect
    @data_request = current_user.data_requests
                                .submittable
                                .includes(:final_legal_document)
                                .find_by(id: params[:id])
    empty_response_or_root_path(datasets_path) unless @data_request && @data_request.datasets.count.positive?
  end

  def find_deletable_data_request_or_redirect
    @data_request = current_user.data_requests.deletable.find_by(id: params[:id])
    empty_response_or_root_path(data_requests_path) unless @data_request
  end

  def send_signature(attribute)
    send_file_if_present @data_request.send(attribute)
  end

  def save_data_request_user(user: current_user, redirect: true)
    @data_request = @dataset.data_requests.find_by(user: user, status: ["resubmit", "started"])
    if @data_request
      redirect_to resume_url(@data_request) if redirect
    else
      final_legal_document = @dataset.final_legal_document_for_user(user) if @dataset
      if final_legal_document
        @data_request = user.data_requests.new(
          dataset_ids: @dataset.id, final_legal_document: final_legal_document
        )
        AgreementTransaction.save_agreement!(@data_request, user, request.remote_ip, "agreement_create")
        @data_request.agreement_events.create(event_type: "user_started", user: user, event_at: @data_request.created_at)
        redirect_to resume_url(@data_request) if redirect
      else
        redirect_to data_requests_no_legal_documents_path(@dataset) if redirect
      end
    end
  end

  def user_params
    params.require(:user).permit(:username, :email, :password)
  end

  def resume_url(data_request)
    if data_request.final_legal_document.final_legal_document_pages.count.positive?
      data_requests_page_path(data_request, data_request.current_step.positive? ? data_request.current_step : 1)
    elsif data_request.attestation_required?
      data_requests_attest_path(data_request)
    else
      data_requests_proof_path(data_request)
    end
  end

  def data_request_params
    params[:data_request] ||= { blank: "1" }
    params[:data_request][:dataset_ids] = clean_dataset_ids
    params.require(:data_request).permit(
      dataset_ids: []
    )
  end

  def clean_dataset_ids
    @data_request.final_legal_document.legal_document.datasets.where(id: params[:data_request][:dataset_ids]).pluck(:id)
  end
end
