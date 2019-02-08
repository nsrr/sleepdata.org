# frozen_string_literal: true

# Displays public organizations on the NSRR.
class OrganizationsController < ApplicationController
  before_action :find_organization_or_redirect, only: [:show]

  # GET /orgs
  def index
    @organizations = Organization.current.search(params[:search]).order(:name).page(params[:page]).per(20)
    # render layout: "layouts/full_page_sidebar" if current_user&.organization_viewer?
  end

  # # GET /orgs/1
  # def show
  # end

  private

  def find_organization_or_redirect
    super(:id)
  end
end
