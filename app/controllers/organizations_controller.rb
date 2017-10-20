# frozen_string_literal: true

# Allows admins to manage organizations and assign organization owners.
class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin
  before_action :find_organization_or_redirect, only: [
    :show, :edit, :update, :destroy,
    :datasets,
    :people, :invite_member, :add_member
  ]

  # GET /organizations
  def index
    @organizations = Organization.current.search(params[:search]).order(:name).page(params[:page]).per(20)
  end

  # # GET /organizations/1
  # def show
  # end

  # GET /organizations/1/datasets
  def datasets
    @datasets = @organization.datasets
  end

  # GET /organizations/1/people
  def people
    @users = User.where(id: current_user.id)
  end

  # # GET /organizations/1/people/invite
  # def invite_member
  # end

  # POST /organizations/1/people/invite
  def add_member
    redirect_to people_organization_path(@organization)
  end

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
    super(:id)
  end

  def organization_params
    params.require(:organization).permit(:name, :slug)
  end
end
