# frozen_string_literal: true

# Dedicated to admin-only tasks of the site
class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin

  # GET /admin/agreement-reports
  def agreement_reports
    @agreements = Agreement.current.regular_members
  end

  # # GET /admin/roles
  # def roles
  # end

  # # GET /admin/stats
  # def stats
  # end

  # # GET /admin/sync
  # def sync
  # end

  # # GET /admin/downloads-by-month
  # def downloads_by_month
  # end

  # GET /admin/downloads-by-quarter
  def downloads_by_quarter
    @year = params[:year].to_i.positive? ? params[:year].to_i : Time.zone.today.year
  end
end
