# Displays personal member pages
class InternalController < ApplicationController
  before_action :authenticate_user!

  def dashboard
  end

  # def settings
  # end

  def submissions
  end

  # def tools
  # end

  def profile
  end

  def token
  end
end
