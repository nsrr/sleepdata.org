# frozen_string_literal: true

# TODO: Remove controller.

# Allows reviewers to view and update data requests.
class AgreementsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  # TODO: Move to organizations (or into principal_reviewer/data_requests controller).
  # GET /agreements/export
  def export
    # TODO: Change this to be based on the current organization.
    organization = current_user.organizations.first
    @export = current_user.exports.create(
      name: "#{organization.name} Data Requests #{Time.zone.now.strftime("%b %-d, %Y")}",
      organization: organization
    )
    @export.generate_export_in_background!
    redirect_to @export, notice: "Export started."
  end
end
