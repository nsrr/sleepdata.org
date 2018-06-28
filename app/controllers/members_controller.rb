# frozen_string_literal: true

# Displays member profile pages.
class MembersController < ApplicationController
  before_action :find_member, only: [:profile_picture]
  before_action :find_member_or_redirect, only: [:show, :posts, :tools]

  def index
    redirect_to topics_path
  end

  # GET /members/:username
  def show
    redirect_to posts_member_path(params[:id])
  end

  # GET /members/:username/profile_picture
  def profile_picture
    if @member&.profile_picture&.thumb.present?
      send_file(@member&.profile_picture&.thumb&.path)
    else
      file_path = Rails.root.join("app", "assets", "images", "member-secret.png")
      File.open(file_path, "r") do |f|
        send_data f.read, type: "image/png", filename: "member.png"
      end
    end
  end

  # GET /members/:username
  def show
    redirect_to posts_member_path(params[:id])
  end

  # GET /members/:username/posts
  def posts
    @replies = @member.replies.order(created_at: :desc).page(params[:page]).per(10)
    @topics = @member.topics.order("replies_count desc").limit(3)
    @recent_topics = @member.topics.where.not(id: @topics).limit(3)
  end

  def tools
    @tools = @member.community_tools.published.order(Arel.sql("LOWER(community_tools.name)")).page(params[:page]).per(10)
  end

  private

  def find_member
    @member = User.current.find_by("LOWER(username) = ?", params[:id].to_s.downcase)
  end

  def find_member_or_redirect
    find_member
    empty_response_or_root_path(members_path) unless @member
  end
end
