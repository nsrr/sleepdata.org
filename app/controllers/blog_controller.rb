# Publicly available and published blog posts
class BlogController < ApplicationController
  before_action :set_broadcast, only: [:show]

  def blog
    @broadcasts = Broadcast.current.published.order(publish_date: :desc).page(params[:page]).per(10)
  end

  def show
  end

  private

  def set_broadcast
    @broadcast = Broadcast.current.published.find_by_id(params[:id])
    redirect_to blog_path unless @broadcast
  end
end
