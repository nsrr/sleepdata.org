# frozen_string_literal: true

# Displays user settings pages.
class SettingsController < ApplicationController
  before_action :authenticate_user!

  layout "layouts/full_page_sidebar"

  # # GET /settings/profile
  # def profile
  # end

  # PATCH /settings/profile
  def update_profile
    if current_user.update(profile_params)
      redirect_to settings_profile_path, notice: "Profile successfully updated."
    else
      render :profile
    end
  end

  # PATCH /settings/profile/picture
  def update_profile_picture
    if current_user.update(profile_picture_params)
      redirect_to settings_profile_path, notice: "Profile picture successfully updated."
    else
      render :profile
    end
  end

  # # GET /settings/account
  # def account
  # end

  # PATCH /settings/account
  def update_account
    if current_user.update(account_params)
      redirect_to settings_account_path, notice: "Account successfully updated."
    else
      render :account
    end
  end

  # PATCH /settings/password
  def update_password
    if current_user.valid_password?(params[:user][:current_password])
      if current_user.reset_password(params[:user][:password], params[:user][:password_confirmation])
        bypass_sign_in current_user
        redirect_to settings_account_path, notice: "Your password has been changed."
      else
        render :account
      end
    else
      current_user.errors.add(:current_password, "is invalid")
      render :account
    end
  end

  # DELETE /settings/account
  def destroy
    current_user.destroy
    sign_out current_user
    redirect_to root_path, notice: "Your account has been permanently deleted."
  end

  # # GET /settings/email
  # def email
  # end

  # PATCH /settings/email
  def update_email
    if current_user.update(email_params)
      redirect_to settings_email_path, notice: I18n.t("devise.confirmations.send_instructions")
    else
      render :email
    end
  end

  # # GET /settings/data-requests
  # def data_requests
  # end

  # PATCH /settings/data-requests
  def update_data_requests
    if current_user.update(data_request_params)
      redirect_to settings_data_requests_path, notice: "Preferences successfully updated."
    else
      render :data_requests
    end
  end

  private

  def profile_params
    params.require(:user).permit(:username, :profile_bio, :profile_url, :profile_location)
  end

  def profile_picture_params
    params.require(:user).permit(:profile_picture)
  end

  def account_params
    params.require(:user).permit(:full_name)
  end

  def email_params
    params.require(:user).permit(:email, :emails_enabled)
  end

  def data_request_params
    params.require(:user).permit(:data_user_type, :commercial_type)
  end
end
