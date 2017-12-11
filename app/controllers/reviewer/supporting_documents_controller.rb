# frozen_string_literal: true

# Allows reviewers to modify data request supporting documents.
class Reviewer::SupportingDocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_data_request_or_redirect
  before_action :find_supporting_document_or_redirect, only: [:show, :destroy]

  # GET /reviewer/:data_request_id/supporting-documents
  def index
    @supporting_documents = @data_request
                            .supporting_documents
                            .order(Arel.sql("lower(document)"))
                            .page(params[:page])
                            .per(40)
  end

  # GET /reviewer/:data_request_id/supporting-documents/:id
  def show
    send_file_if_present @supporting_document.document, disposition: "inline"
  end

  # GET /reviewer/:data_request_id/supporting-documents/new
  def new
    @supporting_document = @data_request.supporting_documents.new
  end

  # POST /reviewer/:data_request_id/supporting-documents
  def create
    @supporting_document = @data_request.supporting_documents.new(supporting_document_params)
    if @supporting_document.save
      redirect_to(
        reviewer_supporting_documents_path(@data_request),
        notice: "Supporting document was successfully created."
      )
    else
      render :new
    end
  end

  # POST /reviewer/:data_request_id/supporting-documents/upload.js
  def create_multiple
    params[:documents].each do |document|
      @data_request.supporting_documents.create(document: document, reviewer_uploaded: true)
    end
    @supporting_documents = @data_request.supporting_documents.page(params[:page]).per(40)
    render :index
  end

  # DELETE /reviewer/:data_request_id/supporting-documents/1.js
  def destroy
    @supporting_document.destroy
    render :index if @data_request.supporting_documents.count.zero?
  end

  private

  def find_data_request_or_redirect
    @data_request = current_user.reviewable_data_requests.find_by(id: params[:data_request_id])
    empty_response_or_root_path(reviews_path) unless @data_request
  end

  def find_supporting_document_or_redirect
    @supporting_document = @data_request.supporting_documents.find_by(id: params[:id])
    empty_response_or_root_path(review_path(@data_request)) unless @supporting_document
  end

  def supporting_document_params
    params[:supporting_document] ||= { blank: "1" }
    params[:supporting_document][:reviewer_uploaded] = true
    params.require(:supporting_document).permit(:document, :reviewer_uploaded)
  end
end
