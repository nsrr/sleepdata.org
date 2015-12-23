# TODO: Remove/refactor controller
class WelcomeController < ApplicationController
  before_action :authenticate_user!,        only: [:sync, :stats, :agreement_reports, :downloads_by_month, :location, :token, :reviews_index, :reviews_show]
  before_action :check_system_admin,        only: [:sync, :stats, :agreement_reports, :downloads_by_month, :location, :reviews_index, :reviews_show]

  def aug
    @users = User.aug_members.order(:last_name, :first_name)
  end

  def agreement_reports
    @agreements = Agreement.current.regular_members
  end
end
