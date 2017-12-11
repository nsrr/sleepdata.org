# frozen_string_literal: true

# Allows users to upload supporting documents to a data request.
class SupportingDocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_submittable_data_request_or_redirect, except: [:show]
  before_action :find_any_data_request_or_redirect, only: [:show]
  before_action :find_supporting_document_or_redirect, only: [:show]
  before_action :find_deletable_supporting_document_or_redirect, only: [:destroy]

  layout "layouts/full_page"

  # GET /data/requests/:data_request_id/supporting-documents
  def index
    @supporting_documents = @data_request.supporting_documents.order(Arel.sql("lower(document)")).page(params[:page]).per(40)
  end

  # GET /data/requests/:data_request_id/supporting-documents/1
  def show
    send_file_if_present @supporting_document.document, disposition: "inline"
  end

  # GET /data/requests/:data_request_id/supporting-documents/new
  def new
    @supporting_document = @data_request.supporting_documents.new
  end

  # POST /data/requests/:data_request_id/supporting-documents
  def create
    @supporting_document = @data_request.supporting_documents.new(supporting_document_params)
    if @supporting_document.save
      redirect_to [@data_request, :supporting_documents], notice: "Supporting document was successfully created."
    else
      render :new
    end
  end

  # POST /data/requests/:data_request_id/supporting-documents/upload.js
  def create_multiple
    params[:documents].each do |document|
      @data_request.supporting_documents.create(document: document)
    end
    @supporting_documents = @data_request.supporting_documents.page(params[:page]).per(40)
    render :index
  end

  # DELETE /data/requests/:data_request_id/supporting-documents/1.js
  def destroy
    @supporting_document.destroy
    render :index if @data_request.supporting_documents.count.zero?
  end

  private

  def find_submittable_data_request_or_redirect
    @data_request = current_user.data_requests.submittable.find_by(id: params[:data_request_id])
    empty_response_or_root_path unless @data_request
  end

  def find_any_data_request_or_redirect
    @data_request = current_user.data_requests.find_by(id: params[:data_request_id])
    empty_response_or_root_path unless @data_request
  end

  def find_supporting_document_or_redirect
    @supporting_document = @data_request.supporting_documents.find_by(id: params[:id])
    empty_response_or_root_path unless @supporting_document
  end

  def find_deletable_supporting_document_or_redirect
    @supporting_document = @data_request.supporting_documents.where(reviewer_uploaded: false).find_by(id: params[:id])
    empty_response_or_root_path unless @supporting_document
  end

  def supporting_document_params
    params.require(:supporting_document).permit(:document)
  end
end
