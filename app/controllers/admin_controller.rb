class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin


end
