# frozen_string_literal: true

# Provides methods for logging in and registering using AJAX.
class Async::BaseController < ApplicationController
  def login
    unless current_user
      user = User.find_by_email params[:email]
      if user && user.valid_password?(params[:password])
        sign_in(:user, user)
      elsif user
        @error = :password
      else
        @error = :email
      end
    end
  end

  def register
  end
end
