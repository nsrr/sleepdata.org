# frozen_string_literal: true

# Steps users through requesting dataset access.
class DataRequestsController < ApplicationController
  before_action :authenticate_user!, except: [:start, :create, :join, :login]
  before_action :find_viewable_dataset_or_redirect, only: [
    :start, :create, :join, :login,
    :request_as_individual_or_organization,
    :update_individual_or_organization,
    :intended_use_noncommercial_or_commercial,
    :update_noncommercial_or_commercial
  ]
  before_action :find_data_request_or_redirect, except: [
    :index,
    :start, :create, :join, :login,
    :request_as_individual_or_organization,
    :update_individual_or_organization,
    :intended_use_noncommercial_or_commercial,
    :update_noncommercial_or_commercial
  ]

  layout "layouts/full_page"

  # GET /data/requests
  def index
    @data_requests = current_user.data_requests.order(id: :desc).page(params[:page]).per(10)
    render layout: "layouts/application"
  end

  # GET /data/requests/:dataset_id/start
  def start
    @data_request = @dataset.data_requests.find_by(user: current_user, status: ["resubmit", "started"])
    redirect_to data_requests_page_path(@data_request, 1) if current_user && @data_request
  end

  # POST /data/requests/:dataset_id/start
  def create
    if current_user
      save_data_request_user
    else
      render :about_me, layout: "layouts/application"
    end
  end

  # POST /data/requests/:dataset_id/join
  def join
    unless current_user
      user = User.new(user_params)
      if RECAPTCHA_ENABLED && !verify_recaptcha
        @registration_errors = { recaptcha: "reCAPTCHA verification failed." }
        render :about_me
        return
      elsif user.save
        user.send_welcome_email_with_password_in_background(params[:user][:password])
        sign_in(:user, user)
      else
        @registration_errors = user.errors
        render :about_me
        return
      end
    end

    save_data_request_user
  end

  # POST /data/requests/:dataset_id/login
  def login
    @agreement = Agreement.new
    unless current_user
      user = User.find_by_email params[:email]
      if user && user.valid_password?(params[:password])
        sign_in(:user, user)
      else
        @sign_in_errors = []
        @sign_in = true
        render :about_me
        return
      end
    end

    save_data_request_user
  end


  # TODO: See if this is needed to launch agreement.
  # # POST /data/requests/:dataset_id/start/:final_legal_document_id
  # def create
  # end

  # GET /data/requests/:dataset_id/request-as/individual-or-organization
  def request_as_individual_or_organization
    render layout: "layouts/application"
  end

  # POST /data/requests/:dataset_id/request-as/individual-or-organization
  def update_individual_or_organization
    current_user.update(data_user_type: params[:data_user_type]) if %w(individual organization).include?(params[:data_user_type])
    redirect_to data_requests_start_path(@dataset)
  end

  # GET /data/requests/:dataset_id/intended-use/noncommercial-or-commercial
  def intended_use_noncommercial_or_commercial
    render layout: "layouts/application"
  end

  # POST /data/requests/:dataset_id/intended-use/noncommercial-or-commercial
  def update_noncommercial_or_commercial
    current_user.update(commercial_type: params[:commercial_type]) if %w(noncommercial commercial).include?(params[:commercial_type])
    redirect_to data_requests_start_path(@dataset)
  end

  # POST /data/requests/:data_request_id/convert
  def convert
    current_user.update commercial_type: params[:commercial_type] if %w(commercial noncommercial).include?(params[:commercial_type])
    current_user.update data_user_type: params[:data_user_type] if %w(individual organization).include?(params[:data_user_type])

    # TODO: Make sure data_request is associated to a dataset...
    final_legal_document = @data_request.datasets.first.final_legal_document_for_user(current_user)
    if final_legal_document && @data_request.final_legal_document != final_legal_document
      @data_request.update final_legal_document: final_legal_document
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
      redirect_to data_requests_start_path(@dataset)
    end
  end

  # POST /data/requests/:data_request_id/page/:page
  def update_page
    @final_legal_document_page = @data_request.final_legal_document.final_legal_document_pages.find_by(position: params[:page])
    @data_request.final_legal_document.final_legal_document_variables.each do |variable|
      if params.key?(variable.name)
        agreement_variable = @data_request.agreement_variables.where(final_legal_document_variable_id: variable.id).first_or_create
        agreement_variable.update value: params[variable.name.to_sym]
      end
    end
    @next_page = @data_request.final_legal_document.final_legal_document_pages.find_by(position: @final_legal_document_page.position + 1)

    if params.dig(:data_request, :draft_mode) == "1"
      @data_request.update(current_step: @final_legal_document_page.position)
      redirect_to data_requests_path, notice: "Data request draft saved successfully."
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
    if params.dig(:data_request, :draft_mode) == "1"
      redirect_to data_requests_path, notice: "Data request draft saved successfully."
    end

    # TODO: Save checkbox or signature. (and timestamp.)
    if @data_request.final_legal_document.attestation_type == "signature"
      @data_request.save_signature!(:signature_file, params[:data_uri])
    elsif @data_request.final_legal_document.attestation_type == "checkbox"
      # TODO: Save checkbox.
    end
    redirect_to [@data_request, :supporting_documents]
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
    # TODO: Submit data request.
    if params.dig(:data_request, :draft_mode) == "1"
      redirect_to data_requests_path, notice: "Data request draft saved successfully."
    elsif @data_request.complete?
      @data_request.update(status: "submitted")
      redirect_to data_requests_submitted_path(@data_request)

    # TODO: Implement submission.
  # current_time = Time.zone.now
  # if @agreement.status == "resubmit"
  #   hash = { status: "submitted", resubmitted_at: current_time, last_submitted_at: current_time }
  #   event_type = "user_resubmitted"
  # else
  #   hash = { status: "submitted", submitted_at: current_time, last_submitted_at: current_time }
  #   event_type = "user_submitted"
  # end

  # if !@agreement.fully_filled_out?
  #   render "proof"
  # elsif AgreementTransaction.save_agreement!(@agreement, hash, current_user, request.remote_ip, "agreement_update")
  #   @agreement.agreement_events.create event_type: event_type, user_id: current_user.id, event_at: current_time
  #   @agreement.daua_submitted_in_background
  #   redirect_to complete_agreement_path(@agreement)
  # else
  #   redirect_to submissions_path
  # end

    else
      redirect_to data_requests_proof_path(@data_request), notice: "Please fill out all required fields."
    end

  end

  # # GET /data/requests/:data_request_id/submitted
  # def submitted
  # end

  # # GET /data/requests/:data_request_id/print
  # def print
  # end

  private

  def find_data_request_or_redirect
    @data_request = current_user.data_requests
                                .submittable
                                .includes(:final_legal_document)
                                .find_by(id: params[:data_request_id])
    empty_response_or_root_path(datasets_path) unless @data_request
  end

  def send_signature(attribute)
    send_file_if_present @data_request.send(attribute)
  end

  def save_data_request_user
    @data_request = @dataset.data_requests.find_by(user: current_user, status: ["resubmit", "started"])

    if @data_request
      # TODO: Find current "step" of data request or find pages that are indicated by resubmit
      redirect_to data_requests_page_path(@data_request, @data_request.current_step || 1)
    else
      final_legal_document = @dataset.final_legal_document_for_user(current_user) if @dataset
      if final_legal_document
        @data_request = @dataset.agreements.create(user: current_user, final_legal_document: final_legal_document)
        redirect_to data_requests_page_path(@data_request, page: 1)
      elsif @dataset.specify_data_user_type?(current_user)
        redirect_to data_requests_request_as_individual_or_organization_path(@dataset)
      elsif @dataset.specify_commercial_type?(current_user)
        redirect_to data_requests_intended_use_noncommercial_or_commercial_path(@dataset)
      else
        redirect_to data_requests_no_legal_documents_path(@dataset)
      end
    end
  end

  def user_params
    params[:user] ||= {}
    params[:user][:password] = params[:user][:password_confirmation] = SecureRandom.hex(8)
    params.require(:user).permit(
      :first_name, :last_name, :email,
      :password, :password_confirmation
    )
  end
end
