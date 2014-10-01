module Pageable
  extend ActiveSupport::Concern

  included do
    before_action :set_object,                only: [ :new_page, :create_page, :edit_page, :update_page, :show, :pages, :images, :requests, :pull_changes, :sync ]
    before_action :redirect_without_object,   only: [ :new_page, :create_page, :edit_page, :update_page, :show, :pages, :images, :requests, :pull_changes, :sync ]
    before_action :set_page_path,             only: [ :new_page, :create_page, :edit_page, :update_page, :show, :pages ]
  end

  # GET /(datasets|tools)/1/pages
  def pages
    @term = params[:s].to_s.gsub(/[^\w]/, '')
    if @page_path and File.file?(@page_path) and [@object.find_page_folder(params[:path]), File.basename(@page_path)].compact.join('/') == params[:path]
      # render text: @object.find_page_folder(params[:path])
      @object.create_page_audit!(current_user, @path, request.remote_ip)
      render 'documentation/pages'
    elsif @page_path and File.directory?(@page_path) and @object.find_page_folder(params[:path]) == params[:path]
      render 'documentation/pages'
    elsif params[:path].blank?
      render 'documentation/pages'
    else
      @path = @object.find_page_folder(params[:path])
      redirect_to_pages_path
    end
  end

  # GET /(datasets|tools)/1/new_page
  def new_page
    render 'documentation/new_page'
  end

  def create_page
    page_name = params[:page_name].to_s.gsub(/[^\w\.\-]/, '').gsub(/^[\.]*/, '')
    @folder_path = @object.find_page_folder(params[:path])
    @page_path = File.join(@object.pages_folder, @folder_path.to_s, page_name.to_s)
    if not File.exist?(@page_path) and not page_name.blank?
      FileUtils.mkdir_p( File.join(@object.pages_folder, @folder_path.to_s) )
      File.open(@page_path, 'w') do |outfile|
        outfile.write params[:page_contents].to_s
      end
      @path = @page_path.gsub(@object.pages_folder + '/', '')
      redirect_to_pages_path
    else
      @errors = {}
      @errors[:page_name] = page_name.blank? ? "Page name can't be blank" : "A page with that name already exists"
      render 'documentation/new_page'
    end
  end

  # GET /(datasets|tools)/1/edit_page
  def edit_page
    unless @page_path and File.file?(@page_path) and File.size(@page_path) < 1.megabyte
      redirect_to_pages_path
    else
      render 'documentation/edit_page'
    end
  end

  # PATCH /(datasets|tools)/1/update_page
  def update_page
    if @page_path and File.file?(@page_path) and params.has_key?(:page_contents)
      File.open(@page_path, 'w') do |outfile|
        outfile.write params[:page_contents].to_s
      end
    end

    redirect_to_pages_path
  end

  def images
    valid_files = Dir.glob(File.join(@object.root_folder, 'images', '**', '*.{jpg,png}')).collect{|i| i.gsub(File.join(@object.root_folder, 'images') + '/', '')}

    @image_file = valid_files.select{|i| i == params[:path] }.first
    if @image_file and params[:inline] != '1'
      send_file File.join( @object.root_folder, 'images', @image_file )
    elsif @image_file
      render 'documentation/images'
    else
      render nothing: true
    end
  end

  def pull_changes
    @object.pull_latest!
    if params[:back] == 'sync'
      redirect_to sync_path
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
      empty_response_or_root_path( @object.class == Dataset ? datasets_path : tools_path ) unless @object
    end

    def redirect_to_pages_path
      if @object.class == Dataset
        redirect_to pages_dataset_path( @object, path: @path )
      else
        redirect_to pages_tool_path( @object, path: @path )
      end
    end

    def set_page_path
      @page_path = @object.find_page(params[:path])
      @path = (@page_path ? @page_path.gsub(@object.pages_folder + '/', '') : nil)
    end

end
