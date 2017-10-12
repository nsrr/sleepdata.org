# frozen_string_literal: true

# Steps users through requesting dataset access.
class DataRequestsController < ApplicationController
  before_action :authenticate_user!, except: [:start]
  before_action :find_viewable_dataset_or_redirect, only: [
    :start, :request_as_individual_or_organization,
    :update_individual_or_organization,
    :intended_use_noncommercial_or_commercial,
    :update_noncommercial_or_commercial
  ]
  before_action :find_data_request_or_redirect, except: [
    :start, :request_as_individual_or_organization,
    :update_individual_or_organization,
    :intended_use_noncommercial_or_commercial,
    :update_noncommercial_or_commercial
  ]

  layout "layouts/full_page"

  # # GET /data/requests/:dataset_id/start
  # def start
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
    @next_page = @data_request.final_legal_document.final_legal_document_pages.find_by(position: @final_legal_document_page.position + 1)
    @data_request.final_legal_document.final_legal_document_variables.each do |variable|
      if params.key?(variable.name)
        agreement_variable = @data_request.agreement_variables.where(final_legal_document_variable_id: variable.id).first_or_create
        agreement_variable.update value: params[variable.name.to_sym]
      end
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
    # TODO: Save checkbox or signature.
    if @data_request.final_legal_document.attestation_type == "signature"
      @data_request.save_signature!(:signature_file, params[:data_uri])
    elsif @data_request.final_legal_document.attestation_type == "checkbox"

    end
    redirect_to data_requests_proof_path(@data_request)
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

  # # GET /data/requests/:data_request_id/addons
  # def addons
  # end

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
    redirect_to data_requests_submitted_path(@data_request)
  end

  # # GET /data/requests/:data_request_id/submitted
  # def submitted
  # end

  # # GET /data/requests/:data_request_id/print
  # def print
  # end

  private

  def find_data_request_or_redirect
    @data_request = current_user.agreements.submittable
                                .includes(:final_legal_document)
                                .find_by(id: params[:data_request_id])
    empty_response_or_root_path(datasets_path) unless @data_request
  end

  def send_signature(attribute)
    signature_file = File.join(
      CarrierWave::Uploader::Base.root, @data_request.send(attribute).url
    )
    if File.exist?(signature_file)
      send_file signature_file
    else
      head :ok
    end
  end
end
