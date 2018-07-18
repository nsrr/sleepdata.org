# frozen_string_literal: true

# Allows organization editors to manage organization settings.
class Editor::OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_organization_or_redirect

  layout "layouts/full_page_sidebar"

  # # GET /orgs/1/settings
  # def settings
  # end

  # # GET /orgs/1/edit
  # def edit
  # end

  # PATCH /orgs/1
  def update
    if @organization.update(organization_params)
      redirect_to [:settings, @organization], notice: "Organization was successfully updated."
    else
      render :edit
    end
  end

  private

  def find_editable_organization_or_redirect
    super(:id)
  end

  def organization_params
    params.require(:organization).permit(:name, :slug)
  end
end
