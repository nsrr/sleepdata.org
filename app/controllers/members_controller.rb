# frozen_string_literal: true

# Displays member profile pages.
class MembersController < ApplicationController
  # GET /members/:username/profile_picture
  def profile_picture
    find_member
    send_file_if_present @member&.profile_picture&.thumb
  end

  private

  def find_member
    @member = User.current.find_by("LOWER(users.username) = ? or users.id = ?", params[:username].to_s.downcase, params[:username].to_i)
  end
end
