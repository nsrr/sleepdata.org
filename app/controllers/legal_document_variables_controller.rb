class LegalDocumentVariablesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin
  before_action :find_organization_or_redirect
  before_action :find_legal_document_or_redirect
  before_action :find_legal_document_variable_or_redirect, only: [:show, :edit, :update, :destroy]

  # # GET /orgs/1/legal-documents/1/variables
  # def index
  #   @legal_document_variables = @legal_document.legal_document_variables.search(params[:search]).order("position nulls last").page(params[:page]).per(20)
  # end

  # # GET /orgs/1/legal-documents/1/variables/1
  # def show
  # end

  # # GET /orgs/1/legal-documents/1/variables/new
  # def new
  #   @legal_document_variable = @legal_document.legal_document_variables.new
  # end

  # GET /orgs/1/legal-documents/1/variables/1/edit.js
  def edit
  end

  # # POST /orgs/1/legal-documents/1/variables
  # def create
  #   @legal_document_variable = @legal_document.legal_document_variables.new(legal_document_variable_params)
  #   if @legal_document_variable.save
  #     redirect_to [@organization, @legal_document, @legal_document_variable], notice: "Legal document variable was successfully created."
  #   else
  #     render :new
  #   end
  # end

  # PATCH /orgs/1/legal-documents/1/variables/1.js
  def update
    if @legal_document_variable.update(legal_document_variable_params)
      # redirect_to [@organization, @legal_document, @legal_document_variable], notice: "Legal document variable was successfully updated."
      render :show
    else
      render :edit
    end
  end

  # # DELETE /orgs/1/legal-documents/1/variables/1
  # def destroy
  #   @legal_document_variable.destroy
  #   redirect_to organization_legal_document_legal_document_variables_path(@organization, @legal_document), notice: "Legal document variable was successfully deleted."
  # end

  private

  def legal_document_variable_params
    params.require(:legal_document_variable).permit(
      :position, :name, :variable_type, :display_name, :description,
      :field_note, :required
    )
  end

  def find_legal_document_variable_or_redirect
    @legal_document_variable = @legal_document.legal_document_variables.find_by(id: params[:id])
    empty_response_or_root_path(organization_legal_document_path(@organization, @legal_document)) unless @legal_document_variable
  end

  def find_legal_document_or_redirect
    @legal_document = @organization.legal_documents.find_by_param(params[:legal_document_id])
    empty_response_or_root_path(organization_legal_documents_path(@organization)) unless @legal_document
  end
end
