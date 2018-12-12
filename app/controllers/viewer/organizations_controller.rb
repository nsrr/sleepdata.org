# frozen_string_literal: true

# Allows organization members to view organization reports.
class Viewer::OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_organization_or_redirect

  layout "layouts/full_page_sidebar"

  # # GET /orgs/1/reports
  # def reports
  # end

  # GET /orgs/:id/reports/data-requests
  def data_requests
    data_requests = @organization.data_requests
    @dataset = @organization.datasets.find_by_param(params[:dataset])
    data_requests = data_requests.joins(:requests).merge(Request.where(dataset: @dataset)) if @dataset
    @year = (params[:year].to_i.positive? ? params[:year].to_i : Time.zone.today.year)
    @chart_title = { text: "#{@organization.name} Data Requests #{@year}#{" for #{@dataset.slug.upcase}" if @dataset}", align: "center" }
    @series = []
    max = 100
    (series, max) = add_average_submitted(data_requests, max)
    @series << series
    (series, max) = add_submitted_data_requests(data_requests, max)
    @series << series
    (series, max) = add_approved_data_requests(data_requests, max)
    @series << series

    @x_axis = { categories: Date::ABBR_MONTHNAMES.last(12), title: { text: "" } }
    @y_axis = { title: { text: "Data Requests" }, max: max }
  end

  # # GET /orgs/:id/reports/this-month
  # def this_month
  # end

  private

  def find_viewable_organization_or_redirect
    @organization = current_user.viewable_organizations.find_by_param(params[:id])
    empty_response_or_root_path(organizations_path) unless @organization
  end

  def month_start_date(year, month)
    Date.parse("#{year}-#{month}-01")
  end

  def month_end_date(year, month)
    month_start_date(year, month).end_of_month
  end

  def year_start_date(year)
    Date.parse("#{year}-01-01")
  end

  def year_end_date(year)
    year_start_date(year).end_of_year
  end

  def add_submitted_data_requests(data_requests, max)
    data = []
    (1..12).each do |month|
      data << data_requests.where("DATE(submitted_at) >= ? and DATE(submitted_at) <= ?", month_start_date(@year, month), month_end_date(@year, month)).count
    end
    max = ([max] + data).max
    [{ type: "line", showInLegend: true, name: "Submitted Data Requests", data: data, color: "#2196f3", legendIndex: 0 }, max]
  end

  def add_approved_data_requests(data_requests, max)
    data = []
    (1..12).each do |month|
      data << data_requests.where("DATE(approval_date) >= ? and DATE(approval_date) <= ?", month_start_date(@year, month), month_end_date(@year, month)).count
    end
    max = ([max] + data).max
    [{ type: "line", showInLegend: true, name: "Approved Data Requests", data: data, color: "#4caf50", legendIndex: 2 }, max]
  end

  def add_average_submitted(data_requests, max)
    first_submitted_data_request = data_requests.order(submitted_at: :asc).first
    first_year = first_submitted_data_request&.submitted_at&.year || Time.zone.today.year
    total_years = Time.zone.today.year - first_year + 1
    data = []
    (1..12).each do |month|
      data << data_requests.where("date_part('month', submitted_at) = ?", month).count / total_years
    end
    max = ([max] + data).max
    [{ type: "area", showInLegend: true, name: "Avg. Submitted Data Requests", data: data, color: "#e3f2fd", visible: true, dashStyle: "shortdot", legendIndex: 1 }, max]
  end
end
