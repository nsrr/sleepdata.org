# frozen_string_literal: true

# Allows legal documents to be created and edited.
class LegalDocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_organization_or_redirect
  before_action :find_legal_document_or_redirect, only: [:show, :edit, :update, :destroy]

  layout "layouts/full_page_sidebar"

  # GET /orgs/1/legal-documents
  def index
    @legal_documents = @organization.legal_documents.search(params[:search]).order(:name).page(params[:page]).per(20)
  end

  # # GET /orgs/1/legal-documents/1
  # def show
  # end

  # GET /orgs/1/legal-documents/new
  def new
    @legal_document = @organization.legal_documents.new
  end

  # # GET /orgs/1/legal-documents/1/edit
  # def edit
  # end

  # POST /orgs/1/legal-documents
  def create
    @legal_document = @organization.legal_documents.new(legal_document_params)
    if @legal_document.save
      redirect_to [@organization, @legal_document], notice: "Legal document was successfully created."
    else
      render :new
    end
  end

  # PATCH /orgs/1/legal-documents/1
  def update
    if @legal_document.update(legal_document_params)
      redirect_to [@organization, @legal_document], notice: "Legal document was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /orgs/1/legal-documents/1
  def destroy
    @legal_document.destroy
    redirect_to organization_legal_documents_path(@organization), notice: "Legal document was successfully deleted."
  end

  private

  def legal_document_params
    params.require(:legal_document).permit(
      :name, :slug, :commercial_type, :data_user_type, :attestation_type,
      :approval_process
    )
  end

  def find_legal_document_or_redirect
    @legal_document = @organization.legal_documents.find_by_param(params[:id])
    redirect_without_legal_document
  end

  def redirect_without_legal_document
    empty_response_or_root_path(organization_legal_documents_path(@organization)) unless @legal_document
  end
end
