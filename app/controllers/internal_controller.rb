# frozen_string_literal: true

# Displays personal member pages.
class InternalController < ApplicationController
  before_action :authenticate_user!

  # # GET /dashboard
  # def dashboard
  # end

  # # GET /token
  # def token
  # end
end
