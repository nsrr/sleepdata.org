class HostingRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin

  before_action :set_hosting_request, only: [:show, :edit, :update, :destroy]

  # GET /hosting_requests
  def index
    @hosting_requests = HostingRequest.current.all
  end

  # GET /hosting_requests/1
  def show
  end

  # # GET /hosting_requests/new
  # def new
  #   @hosting_request = HostingRequest.new
  # end

  # GET /hosting_requests/1/edit
  def edit
  end

  # # POST /hosting_requests
  # def create
  #   @hosting_request = HostingRequest.new(hosting_request_params)
  #   if @hosting_request.save
  #     redirect_to @hosting_request, notice: 'Hosting request was successfully created.'
  #   else
  #     render :new
  #   end
  # end

  # PATCH/PUT /hosting_requests/1
  def update
    if @hosting_request.update(hosting_request_params)
      redirect_to @hosting_request, notice: 'Hosting request was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /hosting_requests/1
  def destroy
    @hosting_request.destroy
    redirect_to hosting_requests_path, notice: 'Hosting request was successfully destroyed.'
  end

  private

  def set_hosting_request
    @hosting_request = HostingRequest.find(params[:id])
  end

  def hosting_request_params
    params.require(:hosting_request).permit(:description, :institution_name)
  end
end
