# frozen_string_literal: true

# Displays personal member pages.
class InternalController < ApplicationController
  before_action :authenticate_user!
  before_action :check_invite_tokens, only: :dashboard

  layout "layouts/full_page_dashboard"

  # # GET /dashboard
  # def dashboard
  # end

  # # GET /token
  # def token
  # end

  private

  def check_invite_tokens
    redirect_to accept_invite_path if session[:invite_token].present?
  end
end
