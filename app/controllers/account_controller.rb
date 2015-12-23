class AccountController < ApplicationController
  before_action :authenticate_user_from_token!

  def profile
    render json: { authenticated: false } unless current_user
  end
end
