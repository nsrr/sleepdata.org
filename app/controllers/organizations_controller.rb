# frozen_string_literal: true

# Allows admins to manage organizations and assign organization owners.
class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin
  before_action :find_organization_or_redirect, only: [:show, :edit, :update, :destroy]

  # GET /organizations
  def index
    @organizations = Organization.current.search(params[:search]).order(:name).page(params[:page]).per(20)
  end

  # # GET /organizations/1
  # def show
  # end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end

  # # GET /organizations/1/edit
  # def edit
  # end

  # POST /organizations
  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      redirect_to @organization, notice: "Organization was successfully created."
    else
      render :new
    end
  end

  # PATCH /organizations/1
  def update
    if @organization.update(organization_params)
      redirect_to @organization, notice: "Organization was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /organizations/1
  def destroy
    @organization.destroy
    redirect_to organizations_path, notice: "Organization was successfully deleted."
  end

  private

  def find_organization_or_redirect
    @organization = Organization.current.find_by_param(params[:id])
    redirect_without_organization
  end

  def redirect_without_organization
    empty_response_or_root_path(organizations_path) unless @organization
  end

  def organization_params
    params.require(:organization).permit(:name, :slug)
  end
end
