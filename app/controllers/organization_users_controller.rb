# frozen_string_literal: true

# Handles organization membership and roles.
class OrganizationUsersController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :find_organization_or_redirect, only: [:index]
  before_action :find_editable_organization_or_redirect, except: [:index]
  before_action :find_organization_user_or_redirect, only: [:show, :edit, :update, :destroy]

  # GET /orgs/:organization_id/members
  def index
    @organization_users = \
      @organization.organization_users.joins(:user)
                   .order(Arel.sql("LOWER(users.username)"))
                   .page(params[:page]).per(20)
  end

  # # GET /orgs/:organization_id/members/1
  # def show
  # end

  # GET /orgs/:organization_id/members/new
  def new
    @organization_user = @organization.organization_users.new
  end

  # # GET /orgs/:organization_id/members/1/edit
  # def edit
  # end

  # POST /orgs/:organization_id/members
  def create
    @organization_user = @organization.organization_users.where(creator: current_user).new(organization_user_params)
    if @organization_user.save
      redirect_to [@organization, @organization_user], notice: "Organization member was successfully created."
    else
      render :new
    end
  end

  # PATCH /orgs/:organization_id/members/1
  def update
    if @organization_user.update(organization_user_params)
      redirect_to [@organization, @organization_user], notice: "Organization member was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /orgs/:organization_id/members/1
  def destroy
    @organization_user.destroy
    redirect_to(
      organization_organization_users_path(@organization),
      notice: "Organization member was successfully deleted."
    )
  end

  private

  def find_organization_user_or_redirect
    @organization_user = @organization.organization_users.find_by(id: params[:id])
    empty_response_or_root_path(organization_organization_users_path(@organization)) unless @organization_user
  end

  def organization_user_params
    params.require(:organization_user).permit(
      :editor, :review_role, :invite_email
    )
  end
end
