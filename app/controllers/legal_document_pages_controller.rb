class LegalDocumentPagesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin
  before_action :find_organization_or_redirect
  before_action :find_legal_document_or_redirect
  before_action :find_legal_document_page_or_redirect, only: [:show, :edit, :update, :destroy]

  # GET /orgs/1/legal-documents/1/pages
  def index
    @legal_document_pages = @legal_document.legal_document_pages.search(params[:search]).order("position nulls last", :rider).page(params[:page]).per(20)
  end

  # GET /orgs/1/legal-documents/1/pages/1
  def show
  end

  # GET /orgs/1/legal-documents/1/pages/new
  def new
    @legal_document_page = @legal_document.legal_document_pages.new
  end

  # GET /orgs/1/legal-documents/1/pages/1/edit
  def edit
  end

  # POST /orgs/1/legal-documents/1/pages
  def create
    @legal_document_page = @legal_document.legal_document_pages.new(legal_document_page_params)
    if @legal_document_page.save
      # Workaround: Readable content needs to be set again since "legal_document" isn't set immediately in the "new" method.
      @legal_document_page.update(content: params[:legal_document_page][:readable_content]) if params[:legal_document_page].key?(:readable_content)
      redirect_to [@organization, @legal_document, @legal_document_page], notice: "Legal document page was successfully created."
    else
      render :new
    end
  end

  # PATCH /orgs/1/legal-documents/1/pages/1
  def update
    if @legal_document_page.update(legal_document_page_params)
      redirect_to [@organization, @legal_document, @legal_document_page], notice: "Legal document page was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /orgs/1/legal-documents/1/pages/1
  def destroy
    @legal_document_page.destroy
    redirect_to organization_legal_document_legal_document_pages_path(@organization, @legal_document), notice: "Legal document page was successfully deleted."
  end

  private

  def legal_document_page_params
    params.require(:legal_document_page).permit(:title, :readable_content, :position, :rider)
  end

  def find_legal_document_page_or_redirect
    @legal_document_page = @legal_document.legal_document_pages.find_by_id(params[:id])
    empty_response_or_root_path(organization_legal_document_path(@organization, @legal_document)) unless @legal_document_page
  end

  def find_legal_document_or_redirect
    @legal_document = @organization.legal_documents.find_by_param(params[:legal_document_id])
    empty_response_or_root_path(organization_legal_documents_path(@organization)) unless @legal_document
  end
end
