# frozen_string_literal: true

# Allows organization owners and editors to view and generate data request exports.
class Viewer::ExportsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_organization_or_redirect
  before_action :find_export_or_redirect, only: [
    :show, :progress, :download, :destroy
  ]

  layout "layouts/full_page_sidebar"

  # GET /orgs/:organization_id/exports
  def index
    @exports = current_user.exports.order(id: :desc).page(params[:page]).per(20)
  end

  # # GET /orgs/:organization_id/exports/:id
  # def show
  # end

  # # POST /orgs/:organization_id/exports/:id.js
  # def progress
  # end

  # GET /orgs/:organization_id/exports/:id/download
  def download
    send_file_if_present @export.zipped_file
  end

  # POST /orgs/:organization_id/exports
  def create
    @export = current_user.exports.create(
      name: "#{@organization.slug.presence || @organization.name.parameterize}-data-requests-#{Time.zone.now.strftime("%Y-%m-%d")}",
      organization: @organization
    )
    @export.generate_export_in_background!
    redirect_to [@organization, @export], notice: "Export started."
  end

  # DELETE /orgs/:organization_id/exports/:id
  def destroy
    @export.destroy
    redirect_to organization_exports_path(@organization), notice: "Export was successfully deleted."
  end

  private

  def find_viewable_organization_or_redirect
    @organization = current_user.viewable_organizations.find_by_param(params[:organization_id])
    empty_response_or_root_path(organizations_path) unless @organization
  end

  def find_export_or_redirect
    @export = @organization.exports.where(user: current_user).find_by(id: params[:id])
    empty_response_or_root_path(organization_exports_path(@organization)) unless @export
  end

  def export_params
    params.require(:export).permit(:name, :organization_id)
  end
end
