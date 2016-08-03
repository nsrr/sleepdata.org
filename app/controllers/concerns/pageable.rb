# frozen_string_literal: true

module Pageable
  extend ActiveSupport::Concern

  included do
    before_action :set_object,                only: [:show, :pages, :images, :collaborators, :requests, :pull_changes, :sync]
    before_action :redirect_without_object,   only: [:show, :pages, :images, :collaborators, :requests, :pull_changes, :sync]
    before_action :set_page_path,             only: [:show, :pages]
  end

  # GET /(datasets|tools)/1/pages
  def pages
    @term = params[:s].to_s.gsub(/[^\w]/, '')
    if @page_path && File.file?(@page_path) && [@object.find_page_folder(params[:path]), File.basename(@page_path)].compact.join('/') == params[:path]
      @object.create_page_audit!(current_user, @path, request.remote_ip)
      render 'documentation/pages'
    elsif @page_path && File.directory?(@page_path) && @object.find_page_folder(params[:path]) == params[:path]
      render 'documentation/pages'
    elsif params[:path].blank?
      render 'documentation/pages'
    else
      @path = @object.find_page_folder(params[:path])
      redirect_to_pages_path
    end
  end

  def images
    valid_files = Dir.glob(File.join(@object.root_folder, 'images', '**', '*.{jpg,png}')).collect{|i| i.gsub(File.join(@object.root_folder, 'images') + '/', '')}

    @image_file = valid_files.select{|i| i == params[:path] }.first
    if @image_file and params[:inline] != '1'
      send_file File.join( @object.root_folder, 'images', @image_file )
    elsif @image_file
      render 'documentation/images.html.haml'
    else
      head :ok
    end
  end

  def pull_changes
    @object.pull_latest!
    if params[:back] == 'sync'
      redirect_to admin_sync_path
    elsif @object.class == Dataset
      redirect_to sync_dataset_path(@object)
    elsif @object.class == Tool
      redirect_to sync_tool_path(@object)
    else
      redirect_to @object
    end
  end

  def sync
    @remote_commit = @object.remote_commit
    @local_commit = @object.local_commit

    render 'documentation/sync'
  end

  private

  def set_object
    @object = @dataset || @tool
  end

  def redirect_without_object
    empty_response_or_root_path(@object.class == Dataset ? datasets_path : tools_path) unless @object
  end

  def redirect_to_pages_path
    if @object.class == Dataset
      redirect_to pages_dataset_path(@object, path: @path)
    else
      redirect_to pages_tool_path(@object, path: @path)
    end
  end

  def set_page_path
    @page_path = @object.find_page(params[:path])
    @path = (@page_path ? @page_path.gsub(@object.pages_folder + '/', '') : nil)
  end
end
