# Publicly available and published blog posts
class BlogController < ApplicationController
  before_action :set_broadcast, only: [:show, :image]

  def blog
    @broadcasts = Broadcast.current.published.order(publish_date: :desc).page(params[:page]).per(10)
  end

  def show
  end

  def image
    if @broadcast.image.size > 0
      send_file File.join(CarrierWave::Uploader::Base.root, @broadcast.image.url)
    else
      head :ok
    end
  end

  private

  def set_broadcast
    @broadcast = Broadcast.current.published.find_by_id(params[:id])
    redirect_to blog_path unless @broadcast
  end
end
