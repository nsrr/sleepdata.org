# frozen_string_literal: true

# Allows admins to manage user accounts.
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin, except: [:settings, :update_settings, :change_password]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :redirect_without_user, only: [:show, :edit, :update, :destroy]

  # # GET /settings
  # def settings
  # end

  # PATCH /settings
  def update_settings
    if current_user.update(user_params)
      redirect_to settings_path, notice: 'Settings successfully updated.'
    else
      render :settings
    end
  end

  # PATCH /change_password
  def change_password
    if current_user.valid_password?(params[:user][:current_password])
      if current_user.reset_password(params[:user][:password], params[:user][:password_confirmation])
        bypass_sign_in current_user
        redirect_to settings_path, notice: 'Your password has been changed.'
      else
        render :settings
      end
    else
      current_user.errors.add(:current_password, 'is invalid')
      render :settings
    end
  end

  # GET /users
  def index
    @order = scrub_order(User, params[:order], 'users.current_sign_in_at desc')
    @users = User.current.search(params[:search]).order(@order).page(params[:page]).per(40)
  end

  # # GET /users/1/edit
  # def edit
  # end

  # PATCH /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /users/1
  # DELETE /users/1.js
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_path, notice: 'User was successfully deleted.' }
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
    params[:user] ||= {}
    if current_user.system_admin?
      params.require(:user).permit(
        :first_name, :last_name, :email, :username, :research_summary,
        :degree, :aug_member, :core_member, :system_admin, :community_manager,
        :banned, :emails_enabled, :contributor
      )
    else
      params.require(:user).permit(
        :first_name, :last_name, :email, :username, :research_summary, :emails_enabled
      )
    end
  end
end
