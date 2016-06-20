# frozen_string_literal: true

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

  def agreement_reports
    @agreements = Agreement.current.regular_members
  end

  def downloads_by_month
  end
end
