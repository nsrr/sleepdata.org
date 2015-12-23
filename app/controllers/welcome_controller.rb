# TODO: Remove/refactor controller
class WelcomeController < ApplicationController
  before_action :authenticate_user!,        only: [:sync, :stats, :agreement_reports, :downloads_by_month, :location, :reviews_index, :reviews_show]
  before_action :check_system_admin,        only: [:sync, :stats, :agreement_reports, :downloads_by_month, :location, :reviews_index, :reviews_show]

  def agreement_reports
    @agreements = Agreement.current.regular_members
  end
end
