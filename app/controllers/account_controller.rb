# frozen_string_literal: true

# API to allow user to see if account is authenticated.
class AccountController < ApplicationController
  before_action :authenticate_user_from_token!

  # GET /account/:auth_token/profile.json
  # GET /account/profile.json
  def profile
    render json: { authenticated: false } unless current_user
  end
end
