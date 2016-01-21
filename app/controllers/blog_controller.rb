# Publicly available and published blog posts
class BlogController < ApplicationController
  before_action :set_broadcast, only: [:show]

  def blog
    broadcast_scope = Broadcast.current.published.order(publish_date: :desc)
    unless params[:a].blank?
      user_ids = User.current.with_name(params[:a].to_s.split(','))
      broadcast_scope = broadcast_scope.where(user_id: user_ids.select(:id))
    end
    @broadcasts = broadcast_scope.page(params[:page]).per(40)

    respond_to do |format|
      format.html
      format.atom
    end
  end

  def show
  end

  private

  def set_broadcast
    @broadcast = Broadcast.current.published.find_by_id(params[:id])
    redirect_to blog_path unless @broadcast
  end
end
