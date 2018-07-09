# frozen_string_literal: true

# Allows admins to view all forum topic and blog post replies in one location.
class Admin::RepliesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  layout "layouts/full_page_sidebar"

  # GET /admin/replies
  def index
    @order = scrub_order(Reply, params[:order], "created_at desc")
    @order = params[:order] if ["points", "points desc"].include?(params[:order])
    @replies = Reply.current.points.order(@order).page(params[:page]).per(40)
  end
end
