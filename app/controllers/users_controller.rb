# frozen_string_literal: true

# Allows admins to manage user accounts.
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :redirect_without_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  def index
    @order = scrub_order(User, params[:order], "users.current_sign_in_at desc")
    @users = User.current.search(params[:search]).order(@order).page(params[:page]).per(40)
  end

  # # GET /users/1/edit
  # def edit
  # end

  # PATCH /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: "User was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /users/1
  # DELETE /users/1.js
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_path, notice: "User was successfully deleted." }
      format.js
    end
  end

  private

  def set_user
    @user = User.current.find_by(id: params[:id])
  end

  def redirect_without_user
    empty_response_or_root_path(users_path) unless @user
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :username, :research_summary, :degree,
      :aug_member, :core_member, :system_admin, :community_manager, :banned,
      :emails_enabled, :contributor, :profile_bio, :profile_url,
      :profile_location
    )
  end
end
