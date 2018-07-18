# frozen_string_literal: true

# Allows organization editors to assign legal documents to datasets.
class LegalDocumentDatasetsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_organization_or_redirect
  before_action :find_legal_document_dataset_or_redirect, only: [:show, :edit, :update, :destroy]

  layout "layouts/full_page_sidebar"

  # GET /orgs/1/legal-document-datasets
  def index
    @legal_document_datasets = @organization.legal_document_datasets.page(params[:page]).per(20)
  end

  # # GET /orgs/1/legal-document-datasets/1
  # def show
  # end

  # GET /orgs/1/legal-document-datasets/new
  def new
    @legal_document_dataset = @organization.legal_document_datasets.new
  end

  # # GET /orgs/1/legal-document-datasets/1/edit
  # def edit
  # end

  # POST /orgs/1/legal-document-datasets
  def create
    @legal_document_dataset = @organization.legal_document_datasets.new(legal_document_dataset_params)
    if @legal_document_dataset.save
      redirect_to [@organization, @legal_document_dataset], notice: "Legal document dataset was successfully created."
    else
      render :new
    end
  end

  # PATCH /orgs/1/legal-document-datasets/1
  def update
    if @legal_document_dataset.update(legal_document_dataset_params)
      redirect_to [@organization, @legal_document_dataset], notice: "Legal document dataset was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /orgs/1/legal-document-datasets/1
  def destroy
    @legal_document_dataset.destroy
    redirect_to organization_legal_document_datasets_path(@organization), notice: "Legal document dataset was successfully deleted."
  end

  private

  def legal_document_dataset_params
    params.require(:legal_document_dataset).permit(:legal_document_id, :dataset_id)
  end

  def find_legal_document_dataset_or_redirect
    @legal_document_dataset = @organization.legal_document_datasets.find_by(id: params[:id])
    empty_response_or_root_path(organization_legal_document_datasets_path(@organization)) unless @legal_document_dataset
  end
end
