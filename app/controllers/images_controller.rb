# frozen_string_literal: true

# Allows user to insert images into blog and forum posts
class ImagesController < ApplicationController
  before_action :authenticate_user!, only: [:index, :new, :edit, :create, :create_multiple, :update, :destroy]
  before_action :check_admin, only: [:index, :edit, :update, :destroy]
  before_action :set_image, only: [:show, :download, :edit, :update, :destroy]

  # GET /images
  def index
    @images = Image.order(id: :desc).page(params[:page]).per(40)
    render layout: "layouts/full_page_sidebar"
  end

  # GET /images/1
  def show
    redirect_to images_path unless @image
  end

  def download
    uploader = \
      case params[:size]
      when "preview"
        @image.image.preview
      when "thumb"
        @image.image.thumb
      else
        @image.image
      end
    send_file_if_present uploader
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
    redirect_to images_path unless @image
    render layout: "layouts/full_page_sidebar"
  end

  # POST /images
  def create
    @image = current_user.images.new(image_params)
    if @image.save
      @image.update file_size: @image.image.size
      redirect_to @image, notice: "Image was successfully created."
    else
      render :new
    end
  end

  # POST /:category_id/documents/upload.js
  def create_multiple
    @ids = []
    params[:images].each do |image|
      image = current_user.images.create(image: image, file_size: image.size)
      @ids << image.to_param
    end
  end

  # PATCH/PUT /images/1
  def update
    if @image.update(image_params)
      redirect_to @image, notice: "Image was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /images/1
  def destroy
    @image.destroy
    redirect_to images_path, notice: "Image was successfully deleted."
  end

  private

  def set_image
    @image = Image.find params[:id]
  rescue
    @image = nil
  end

  def image_params
    params.require(:image).permit(:image, :image_cache)
  end
end
