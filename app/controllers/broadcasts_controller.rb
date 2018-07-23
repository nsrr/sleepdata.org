# frozen_string_literal: true

# Allows community managers to view and modify blog posts.
class BroadcastsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_community_manager
  before_action :find_broadcast_or_redirect, only: [:show, :edit, :update, :destroy]

  # layout "layouts/full_page"

  # GET /broadcasts
  def index
    @broadcasts = \
      current_user.editable_broadcasts
                  .search(params[:search], match_start: false)
                  .order(publish_date: :desc, id: :desc)
                  .page(params[:page]).per(20)
  end

  # # GET /broadcasts/1
  # def show
  # end

  # GET /broadcasts/new
  def new
    @broadcast = current_user.broadcasts.new(publish_date: Time.zone.today)
  end

  # # GET /broadcasts/1/edit
  # def edit
  # end

  # POST /broadcasts
  def create
    @broadcast = current_user.broadcasts.new(broadcast_params)
    if @broadcast.save
      redirect_to @broadcast, notice: "Blog post was successfully created."
    else
      render :new
    end
  end

  # PATCH /broadcasts/1
  def update
    if @broadcast.update(broadcast_params)
      redirect_to @broadcast, notice: "Blog post was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /broadcasts/1
  def destroy
    @broadcast.destroy
    redirect_to broadcasts_path, notice: "Blog post was successfully deleted."
  end

  private

  def find_broadcast_or_redirect
    @broadcast = current_user.editable_broadcasts.find_by(slug: params[:id])
    redirect_without_broadcast
  end

  def redirect_without_broadcast
    empty_response_or_root_path(broadcasts_path) unless @broadcast
  end

  def broadcast_params
    params[:broadcast] ||= { blank: "1" }
    parse_date_if_key_present(:broadcast, :publish_date)
    params.require(:broadcast).permit(
      :title, :slug, :short_description, :description, :pinned, :archived,
      :publish_date, :published, :keywords, :category_id, :cover
    )
  end
end
