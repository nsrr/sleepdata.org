class AccountController < ApplicationController
  before_action :authenticate_user_from_token!

  def profile
    if current_user
      render json: { authenticated: true, first_name: current_user.first_name, last_name: current_user.last_name, email: current_user.email }
    else
      render json: { authenticated: false }
    end
  end
end
