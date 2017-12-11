# frozen_string_literal: true

# Displays member profile pages.
class MembersController < ApplicationController
  before_action :find_member, only: [:profile_picture]

  # GET /members/:username/profile_picture
  def profile_picture
    if @member&.profile_picture&.thumb.present?
      send_file(@member&.profile_picture&.thumb&.path)
    else
      if Rails.env.production?
        basename = File.basename(ActionController::Base.helpers.asset_path("member-secret.png"))
        file_path = Rails.root.join("public", "assets", basename)
      else
        file_path = Rails.root.join("app", "assets", "images", "member-secret.png")
      end
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
