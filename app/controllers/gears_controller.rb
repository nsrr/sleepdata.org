class GearsController < ApplicationController
  before_action :find_viewable_dataset_or_redirect
  before_action :find_legal_document_or_redirect, only: [
    :agreement_page, :agreement_signature, :agreement_attest
  ]

  # /agreement/start
  def agreement_start
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
