# frozen_string_literal: true

# Displays public organizations on the NSRR.
class OrganizationsController < ApplicationController
  before_action :find_organization_or_redirect, only: [:show]

  # GET /orgs
  def index
    @organizations = Organization.current.search(params[:search]).order(:name).page(params[:page]).per(20)
  end

  # GET /orgs/1
  def show
    scope = if @organization.viewer?(current_user)
      @organization.datasets
    else
      @organization.datasets.released
    end
    @datasets = scope.search(params[:search], match_start: false).order(:released, Arel.sql("LOWER(name)")).page(params[:page]).per(20)
  end

  private

  def find_organization_or_redirect
    super(:id)
  end
end
