# frozen_string_literal: true

# Publicly available and published blog posts
class BlogController < ApplicationController
  before_action :find_broadcast_or_redirect, only: [:show]

  def blog
    broadcast_scope = Broadcast.current.published.order(publish_date: :desc, id: :desc)
    unless params[:author].blank?
      @author = User.current.with_name(params[:author]).first
      broadcast_scope = broadcast_scope.where(user: @author)
    end
    unless params[:category].blank?
      broadcast_scope = broadcast_scope.joins(:category).merge(Category.current.where(slug: params[:category]))
    end
    @broadcasts = broadcast_scope.page(params[:page]).per(40)

    respond_to do |format|
      format.html
      format.atom
    end
  end

  def show
    @author = @broadcast.user
  end

  private

  def find_broadcast_or_redirect
    @broadcast = Broadcast.current.published.find_by_slug params[:slug]
    redirect_to blog_path unless @broadcast
  end
end
