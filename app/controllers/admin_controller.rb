# Dedicated to admin-only tasks of the site
class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin

  def dashboard
  end

  def location
  end

  def roles
  end

  def stats
  end

  def sync
  end
end
