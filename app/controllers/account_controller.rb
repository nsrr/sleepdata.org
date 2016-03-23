# frozen_string_literal: true

# API to allow user to see if account is authenticated.
class AccountController < ApplicationController
  before_action :authenticate_user_from_token!

  def profile
    render json: { authenticated: false } unless current_user
  end
end
