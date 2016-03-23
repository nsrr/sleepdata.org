# frozen_string_literal: true

# Allows community managers to view and modify blog posts.
class BroadcastsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_community_manager
  before_action :set_broadcast, only: [:show, :edit, :update, :destroy]

  # GET /broadcasts
  def index
    @broadcasts = Broadcast.current.order(publish_date: :desc)
                           .page(params[:page]).per(40)
  end

  # GET /broadcasts/1
  def show
  end

  # GET /broadcasts/new
  def new
    @broadcast = current_user.broadcasts.new(publish_date: Time.zone.today)
  end

  # GET /broadcasts/1/edit
  def edit
  end

  # POST /broadcasts
  def create
    @broadcast = current_user.broadcasts.new(broadcast_params)

    if @broadcast.save
      redirect_to @broadcast, notice: 'Broadcast was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /broadcasts/1
  def update
    if @broadcast.update(broadcast_params)
      redirect_to @broadcast, notice: 'Broadcast was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /broadcasts/1
  def destroy
    @broadcast.destroy
    redirect_to broadcasts_path, notice: 'Broadcast was successfully destroyed.'
  end

  private

  def set_broadcast
    @broadcast = Broadcast.current.find_by_id(params[:id])
  end

  def broadcast_params
    params[:broadcast] ||= { blank: '1' }
    parse_date_if_key_present(:broadcast, :publish_date)
    params.require(:broadcast).permit(
      :title, :short_description, :description, :pinned, :archived,
      :publish_date, :published, :keywords
    )
  end
end
