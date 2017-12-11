# frozen_string_literal: true

# Displays member profile pages.
class MembersController < ApplicationController
  before_action :find_member, only: [:profile_picture]

  # GET /members/:username/profile_picture
  def profile_picture
    if @member&.profile_picture&.thumb.present?
      send_file(@member&.profile_picture&.thumb&.path)
    else
      file_path = (Rails.application.assets || ::Sprockets::Railtie.build_environment(Rails.application))
                  .find_asset("member-secret.png").filename
      send_file(file_path)
    end
  end

  private

  def find_member
    @member = User.current.find_by(
      "LOWER(users.username) = ? or users.id = ?",
      params[:username].to_s.downcase, params[:username].to_i
    )
  end
end
