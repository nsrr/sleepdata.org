class GearsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_dataset_or_redirect
  before_action :find_legal_document_or_redirect, only: [
    :agreement_page, :update_agreement_page, :agreement_attest_signature,
    :update_agreement_attest_signature, :agreement_signature,
    :agreement_duly_authorized_representative_signature, :agreement_attest,
    :update_agreement_attest, :agreement_proof, :agreement_submit
  ]
  before_action :find_final_legal_document_or_redirect, only: [
    :agreement_page, :update_agreement_page, :agreement_attest_signature,
    :update_agreement_attest_signature, :agreement_signature,
    :agreement_duly_authorized_representative_signature, :agreement_attest,
    :update_agreement_attest, :agreement_proof, :agreement_submit
  ]

  # /agreement/start
  def agreement_start
    @agreement = current_user.agreements.find_by(id: params[:agreement_id])
    legal_document = @dataset.legal_document_for_user(current_user)
    if legal_document
      redirect_to agreement_page_path(page: 1, dataset_id: @dataset, legal_document_id: legal_document)
    elsif @dataset.specify_data_user_type?(current_user)
      redirect_to assign_data_user_type_path(dataset_id: @dataset)
    elsif @dataset.specify_commercial_type?(current_user)
      redirect_to assign_commercial_type_path(dataset_id: @dataset)
    else
      redirect_to no_legal_doc_found_path(dataset_id: @dataset)
    end
  end

  # POST /gears/individual-or-organization
  def update_data_user_type
    current_user.update data_user_type: params[:data_user_type] if %w(individual organization).include?(params[:data_user_type])
    redirect_to agreement_start_path(dataset_id: @dataset)
  end

  # POST /gears/noncommercial-or-commercial
  def update_commercial_type
    current_user.update commerical_type: params[:commerical_type] if %w(noncommercial commercial).include?(params[:commerical_type])
    redirect_to agreement_start_path(dataset_id: @dataset)
  end

  # GET /agreement/page/:page
  def agreement_page
    @final_legal_document_page = @final_legal_document.final_legal_document_pages.find_by(position: params[:page])
    if @final_legal_document_page
      render layout: "layouts/full_page"
    else
      redirect_to agreement_start_path(dataset_id: @dataset)
    end
  end

  # POST /agreement/page/:page
  def update_agreement_page
    @final_legal_document_page = @final_legal_document.final_legal_document_pages.find_by(position: params[:page])
    @next_page = @final_legal_document.final_legal_document_pages.find_by(position: @final_legal_document_page.position + 1)
    @final_legal_document.final_legal_document_variables.each do |variable|
      if params.key?(variable.name)
        agreement_variable = @agreement.agreement_variables.where(final_legal_document_variable_id: variable.id).first_or_create
        agreement_variable.update value: params[variable.name.to_sym]
      end
    end

    if @next_page
      redirect_to agreement_page_path(page: @next_page.position, dataset_id: @dataset, legal_document_id: @final_legal_document.legal_document)
    elsif @final_legal_document.attestation_type == "signature"
      redirect_to agreement_attest_signature_path(dataset_id: @dataset, legal_document_id: @final_legal_document.legal_document)
    elsif @final_legal_document.attestation_type == "checkbox"
      redirect_to agreement_attest_path(dataset_id: @dataset, legal_document_id: @final_legal_document.legal_document)
    else # attestation_type == "none"
      redirect_to agreement_proof_path(dataset_id: @dataset, legal_document_id: @final_legal_document.legal_document)
    end
  end

  # GET /agreement/attest/signature
  def agreement_attest_signature
    render layout: "layouts/full_page"
  end

  # GET /agreement/signature/show
  def agreement_signature_show
    signature_file = File.join(CarrierWave::Uploader::Base.root, @agreement.signature_file.url)
    if File.exist?(signature_file)
      send_file signature_file
    else
      head :ok
    end
  end

  # GET /agreement/duly_authorized_representative_signature
  def agreement_duly_authorized_representative_signature
    signature_file = File.join(CarrierWave::Uploader::Base.root, @agreement.duly_authorized_representative_signature_file.url)
    if File.exist?(signature_file)
      send_file signature_file
    else
      head :ok
    end
  end

  # GET /agreement/reviewer_signature
  def agreement_reviewer_signature
    signature_file = File.join(CarrierWave::Uploader::Base.root, @agreement.reviewer_signature_file.url)
    if File.exist?(signature_file)
      send_file signature_file
    else
      head :ok
    end
  end

  # POST /agreement/attest/signature
  def update_agreement_attest_signature
    @agreement.save_signature!(:signature_file, params[:data_uri])
    redirect_to agreement_proof_path(dataset_id: @dataset, legal_document_id: @final_legal_document.legal_document)
  end

  # GET /agreement/attest
  def agreement_attest
    render layout: "layouts/full_page"
  end

  # POST /agreement/attest
  def update_agreement_attest
    # TODO: Save "attestation"
    redirect_to agreement_proof_path(dataset_id: @dataset, legal_document_id: @final_legal_document.legal_document)
  end

  # GET /agreement/proof
  def agreement_proof
    render layout: "layouts/full_page"
  end

  # POST /agreement/proof
  def agreement_submit
    # TODO: Submit agreement
    redirect_to complete_agreement_path(@agreement)
  end

  private

  def find_legal_document_or_redirect
    @legal_document_temp = LegalDocument.current.find_by_param(params[:legal_document_id])
    empty_response_or_root_path(datasets_path) unless @legal_document_temp
  end

  def find_final_legal_document_or_redirect
    @final_legal_document = @legal_document_temp.current_final_legal_document
    @agreement = @dataset.agreements.find_by(user_id: current_user.id, status: ["resubmit", "started"])
    @agreement = @dataset.agreements.create(user_id: current_user.id) unless @agreement
    @agreement.update(final_legal_document: @final_legal_document) if @agreement && @final_legal_document
    empty_response_or_root_path(datasets_path) unless @final_legal_document && @agreement
  end
end
