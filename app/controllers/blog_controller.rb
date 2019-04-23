# frozen_string_literal: true

# Publicly available and published blog posts
class BlogController < ApplicationController
  before_action :find_broadcast_or_redirect, only: [:show, :cover]
  before_action :set_author, only: [:blog]
  before_action :set_category, only: [:blog]

  def blog
    broadcast_scope = Broadcast.current.published.order(publish_date: :desc, id: :desc)
    broadcast_scope = broadcast_scope.where(user: @author) if @author
    broadcast_scope = broadcast_scope.where(category: @category) if @category
    @broadcasts = broadcast_scope.page(params[:page]).per(10)
    respond_to do |format|
      format.html
      format.atom
    end
  end

  def show
    @author = @broadcast.user
    @page = [params[:page].to_i, 1].max
    scope = @broadcast.replies.points.includes(:broadcast).where(reply_id: nil)
    @replies = scope_order(scope).page(params[:page]).per(Reply::REPLIES_PER_PAGE)
    @broadcast.increment! :view_count
    render layout: "layouts/full_page"
  end

  # GET /blog/:slug/cover
  def cover
    send_file_if_present @broadcast.cover
  end

  private

  def find_broadcast_or_redirect
    scope = Broadcast.current
    scope = scope.published unless current_user&.community_manager?
    @broadcast = scope.find_by(slug: params[:slug])
    redirect_to blog_path unless @broadcast
  end

  def set_author
    return if params[:author].blank?

    @author = User.current.where("lower(username) = ?", params[:author].downcase).first
  end

  def set_category
    return if params[:category].blank?

    @category = Category.current.where("lower(slug) = ?", params[:category].downcase).first
  end

  def scope_order(scope)
    @order = params[:order]
    scope.reorder(Arel.sql(Reply::ORDERS[params[:order]] || Reply::DEFAULT_ORDER))
  end
end
