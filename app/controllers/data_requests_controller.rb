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
    :submitted, :print, :show
  ]
  before_action :find_submitted_data_request_or_redirect, only: [:submitted]
  before_action :find_any_data_request_or_redirect, only: [:print, :show]

  layout "layouts/full_page"

  # GET /data/requests
  def index
    @data_requests = current_user.data_requests.order(id: :desc).page(params[:page]).per(10)
    render layout: "layouts/full_page_dashboard"
  end

  # GET /data/requests/:dataset_id/start
  def start
    @data_request = @dataset.data_requests.find_by(user: current_user, status: ["resubmit", "started"])
    return unless current_user && @data_request
    if @data_request.final_legal_document.final_legal_document_pages.count.positive?
      redirect_to data_requests_page_path(@data_request, 1)
    elsif @data_request.attestation_required?
      redirect_to data_requests_attest_path(@data_request)
    else
      redirect_to data_requests_proof_path(@data_request)
    end
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
    unless current_user
      @user = User.new(user_params)
      if RECAPTCHA_ENABLED && !verify_recaptcha
        @user.valid?
        @user.errors.add(:recaptcha, "reCAPTCHA verification failed")
        render :about_me
        return
      elsif @user.save
        @user.send_welcome_email_with_password_in_background(params[:user][:password])
        sign_in(:user, @user)
      else
        render :about_me
        return
      end
    end

    save_data_request_user
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

  # TODO: See if this is needed to launch agreement.
  # # POST /data/requests/:dataset_id/start/:final_legal_document_id
  # def create
  # end

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
      redirect_to data_requests_start_path(@data_request.datasets.first)
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

    if params.dig(:data_request, :draft) == "1"
      @data_request.update(current_step: @final_legal_document_page.position)
      redirect_to @data_request, notice: "Data request draft saved successfully."
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
    if @data_request.final_legal_document.attestation_type == "signature" &&
       params[:data_uri].present? && params[:signature_print].present?
      @data_request.save_signature!(:signature_file, params[:data_uri])
      @data_request.update(
        signature_print: params[:signature_print],
        attested_at: Time.zone.now
      )
    elsif @data_request.final_legal_document.attestation_type == "checkbox"
      if params[:attest] == "1"
        @data_request.update(attested_at: Time.zone.now)
      elsif params[:attest] == "0"
        @data_request.update(attested_at: nil)
      end
    end

    if params.dig(:data_request, :draft) == "1"
      redirect_to @data_request, notice: "Data request draft saved successfully."
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
    @data_request.update(data_request_params)
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
      redirect_to @data_request, notice: "Data request draft saved successfully."
    elsif @data_request.complete?
      current_time = Time.zone.now
      if @data_request.status == "resubmit"
        hash = { status: "submitted", resubmitted_at: current_time, last_submitted_at: current_time }
        event_type = "user_resubmitted"
      else
        hash = { status: "submitted", submitted_at: current_time, last_submitted_at: current_time }
        event_type = "user_submitted"
      end
      if AgreementTransaction.save_agreement!(@data_request, hash, current_user, request.remote_ip, "agreement_update")
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
      send_file @data_request.printed_file.path, filename: "#{@data_request.user.last_name.gsub(/[^a-zA-Z\p{L}]/, '')}-#{@data_request.user.first_name.gsub(/[^a-zA-Z\p{L}]/, '')}-#{@data_request.agreement_number}-data-request-#{(@data_request.submitted_at || @data_request.created_at).strftime("%Y-%m-%d")}.pdf", type: "application/pdf", disposition: "inline"
    else
      render layout: false
    end
  end

  # GET /data/requests/:id
  def show
    render layout: "layouts/full_page_dashboard"
  end

  # # GET /data/requests/:data_request_id/resume
  # def resume
  #  # TODO: Implement a data request resume path (as opposed to "start")
  # end

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

  def send_signature(attribute)
    send_file_if_present @data_request.send(attribute)
  end

  def save_data_request_user
    @data_request = @dataset.data_requests.find_by(user: current_user, status: ["resubmit", "started"])

    if @data_request
      # TODO: Find current "step" of data request or find pages that are indicated by resubmit
      redirect_to data_requests_page_path(@data_request, @data_request.current_step.positive? ? @data_request.current_step : 1)
    else
      final_legal_document = @dataset.final_legal_document_for_user(current_user) if @dataset
      if final_legal_document
        @data_request = @dataset.data_requests.create(user: current_user, final_legal_document: final_legal_document)
        redirect_to data_requests_page_path(@data_request, page: 1)
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
