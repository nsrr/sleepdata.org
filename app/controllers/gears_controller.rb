class GearsController < ApplicationController
  before_action :find_viewable_dataset_or_redirect
  before_action :find_legal_document_or_redirect, only: [
    :agreement_page, :agreement_signature, :agreement_attest
  ]

  # /agreement/start
  def agreement_start
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

  # /agreement/page/:page
  def agreement_page
    @legal_document_page = @legal_document.legal_document_pages.find_by(position: params[:page])
    if @legal_document_page
      render layout: "layouts/full_page"
    else
      redirect_to agreement_start_path(dataset_id: @dataset)
    end
  end

  # /agreement/signature
  def agreement_signature
    render layout: "layouts/full_page"
  end

  # /agreement/attest
  def agreement_attest
    render layout: "layouts/full_page"
  end

  private

  def find_legal_document_or_redirect
    @legal_document = LegalDocument.current.find_by_param(params[:legal_document_id])
    empty_response_or_root_path(datasets_path) unless @legal_document
  end
end
