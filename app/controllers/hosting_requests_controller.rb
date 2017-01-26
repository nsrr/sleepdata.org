# frozen_string_literal: true

# Allows admins to review and respond to hosting requests.
class HostingRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin
  before_action :find_hosting_request_or_redirect, only: [:show, :edit, :update, :destroy]

  # GET /hosting-requests
  def index
    @order = scrub_order(HostingRequest, params[:order], 'hosting_requests.institution_name')
    @hosting_requests = HostingRequest.current.search(params[:search])
                                      .order(@order).page(params[:page]).per(40)
  end

  # GET /hosting-requests/1
  def show
  end

  # # GET /hosting-requests/new
  # def new
  #   @hosting_request = HostingRequest.new
  # end

  # GET /hosting-requests/1/edit
  def edit
  end

  # # POST /hosting-requests
  # def create
  #   @hosting_request = HostingRequest.new(hosting_request_params)
  #   if @hosting_request.save
  #     redirect_to @hosting_request, notice: 'Hosting request was successfully created.'
  #   else
  #     render :new
  #   end
  # end

  # PATCH /hosting-requests/1
  def update
    if @hosting_request.update(hosting_request_params)
      redirect_to @hosting_request, notice: 'Hosting request was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /hosting-requests/1
  def destroy
    @hosting_request.destroy
    redirect_to hosting_requests_path, notice: 'Hosting request was successfully deleted.'
  end

  private

  def find_hosting_request_or_redirect
    @hosting_request = HostingRequest.current.find_by(id: params[:id])
    redirect_without_hosting_request
  end

  def redirect_without_hosting_request
    empty_response_or_root_path(hosting_requests_path) unless @hosting_request
  end

  def hosting_request_params
    params.require(:hosting_request).permit(
      :institution_name, :description, :reviewed
    )
  end
end
