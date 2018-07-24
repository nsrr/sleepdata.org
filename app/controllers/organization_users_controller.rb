# frozen_string_literal: true

# Handles organization membership and roles.
class OrganizationUsersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :invite]
  before_action :find_organization_or_redirect, only: [:index]
  before_action :find_editable_organization_or_redirect, except: [:index, :invite, :accept_invite]
  before_action :find_organization_user_or_redirect, only: [:show, :edit, :update, :destroy]

  # GET /orgs/:organization_id/members
  def index
    @organization_users = \
      if @organization.editor?(current_user) && params[:pending] == "1"
        @organization.organization_users.where(user_id: nil)
                     .order(:invite_email)
                     .page(params[:page]).per(20)
      else
        @organization.organization_users.joins(:user)
                     .order(Arel.sql("LOWER(users.username)"))
                     .page(params[:page]).per(20)
      end
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
    email = params[:organization_user][:invite_email].to_s.strip
    @organization_user = @organization.organization_users.find_by(invite_email: email) if email.present?
    if @organization_user
      @organization_user.creator_id = current_user.id
      @organization_user.review_role = params[:organization_user][:review_role]
      @organization_user.editor = params[:organization_user][:editor]
    else
      @organization_user = @organization.organization_users.where(creator: current_user).new(organization_user_params)
    end

    if @organization_user.save
      @organization_user.send_invite_email_in_background!
      redirect_to organization_organization_users_path(@organization), notice: "Organization member was successfully invited."
    else
      render :new
    end
  end

  # GET /invite/:invite_token
  def invite
    session[:invite_token] = params[:invite_token]
    if current_user
      redirect_to accept_invite_path
    else
      redirect_to new_user_session_path
    end
  end

  # GET /accept-invite
  def accept_invite
    invite_token = session.delete(:invite_token)
    @organization_user = OrganizationUser.find_by(invite_token: invite_token)
    if @organization_user
      @organization_user.update(user: current_user, invite_email: nil, invite_token: nil)
      redirect_to @organization_user.organization, notice: "Invite successfully accepted."
    else
      redirect_to root_path, alert: "Invitation already accepted."
    end
  end

  # PATCH /orgs/:organization_id/members/1
  def update
    if @organization_user.update(organization_user_params)
      redirect_to organization_organization_users_path(@organization), notice: "Organization member was successfully updated."
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
