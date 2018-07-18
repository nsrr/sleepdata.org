# frozen_string_literal: true

# Allows admins to create and delete organizations.
class Admin::OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin
  before_action :find_organization_or_redirect, only: [:destroy]

  layout "layouts/full_page_sidebar"

  # GET /orgs/new
  def new
    @organization = Organization.new
  end

  # POST /orgs
  def create
    @organization = Organization.new(organization_params)
    if @organization.save
      @organization.organization_users.create(creator: current_user, user: current_user, editor: true)
      redirect_to @organization, notice: "Organization was successfully created."
    else
      render :new
    end
  end

  # DELETE /orgs/1
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
