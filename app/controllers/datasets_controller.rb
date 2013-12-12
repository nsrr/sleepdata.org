class DatasetsController < ApplicationController
  before_action :authenticate_user!,        only: [ :new, :edit, :create, :update, :destroy, :audits, :requests, :request_access, :set_access, :new_page, :create_page, :edit_page, :update_page ]
  before_action :check_system_admin,        only: [ :new, :create, :destroy ]
  before_action :set_viewable_dataset,      only: [ :show, :manifest, :logo, :images, :variable_chart, :files, :pages, :request_access, :search, :add_variable_to_list, :remove_variable_from_list ]
  before_action :set_editable_dataset,      only: [ :edit, :update, :destroy, :audits, :requests, :set_access, :new_page, :create_page, :edit_page, :update_page ]
  before_action :redirect_without_dataset,  only: [ :show, :manifest, :logo, :images, :variable_chart, :files, :pages, :edit, :update, :destroy, :audits, :requests, :request_access, :set_access, :new_page, :create_page, :edit_page, :update_page, :search, :add_variable_to_list, :remove_variable_from_list ]
  before_action :set_page_path,             only: [ :pages, :new_page, :create_page, :edit_page, :update_page, :show ]

  def add_variable_to_list
    if variable = @dataset.variables.find_by_id( params[:variable_id] )
      @list = List.where( id: cookies.signed[:list_id] ).first_or_create( user_id: current_user ? current_user.id : nil )
      cookies.signed[:list_id] = @list.id
      unless @list.variable_ids.include?([variable.dataset_id, variable.name])
        @list.variable_ids << [variable.dataset_id, variable.name]
        @list.save
      end
    end
  end

  def remove_variable_from_list
    if variable = @dataset.variables.find_by_id( params[:variable_id] ) and @list = List.find_by_id( cookies.signed[:list_id] )
      @list.variable_ids.delete( [variable.dataset_id, variable.name] )
      @list.save
    end
    render 'add_variable_to_list'
  end

  def request_access
    if @dataset_user = @dataset.dataset_users.where( user_id: current_user.id ).first
      # Dataset access has already been requested
    else
      @dataset_user = @dataset.dataset_users.create( user_id: current_user.id, editor: false, approved: nil )
    end
    redirect_to @dataset
  end

  def set_access
    if @dataset_user = @dataset.dataset_users.find_by_id(params[:dataset_user_id])
      @dataset_user.update( editor: params[:editor], approved: params[:approved] )
    end
    redirect_to requests_dataset_path(@dataset)
  end

  # GET /datasets/1/file_audits
  def audits
    audit_scope = @dataset.dataset_file_audits.order( created_at: :desc )
    audit_scope = audit_scope.where( user_id: params[:user_id].blank? ? nil : params[:user_id] ) if params.has_key?(:user_id)
    audit_scope = audit_scope.where( medium: params[:medium].blank? ? nil : params[:medium] ) if params.has_key?(:medium)
    audit_scope = audit_scope.where( remote_ip: params[:remote_ip].blank? ? nil : params[:remote_ip] ) if params.has_key?(:remote_ip)
    @audits = audit_scope
  end

  # GET /datasets/1/search
  def search
    @term = params[:s].to_s.gsub(/[^\w]/, '')
    @results = []
    @results = `grep -i -R #{@term} #{@dataset.pages_folder}`.split("\n") unless @term.blank?
  end

  # GET /datasets/1/manifest.txt
  def manifest
    @folder_path = @dataset.find_file_folder(params[:path])
    render text: @dataset.indexed_files(@folder_path, -1).select{|folder, file_name, is_file, file_size, file_time| is_file}.collect{|folder, file_name, is_file, file_size, file_time| site_prefix + files_dataset_path(@dataset, path: folder, auth_token: (current_user ? current_user.authentication_token : nil ), medium: 'wget')}.join("\n\r")
  end

  def logo
    send_file File.join( CarrierWave::Uploader::Base.root, @dataset.logo.url )
  end

  def images
    valid_files = Dir.glob(File.join(@dataset.root_folder, 'images', '**', '*.{jpg,png}')).collect{|i| i.gsub(File.join(@dataset.root_folder, 'images') + '/', '')}

    @image_file = valid_files.select{|i| i == params[:path] }.first
    if @image_file and params[:inline] != '1'
      send_file File.join( @dataset.root_folder, 'images', @image_file )
    elsif not @image_file
      render nothing: true
    end
  end

  def variable_chart
    name = params[:name].to_s.gsub(/[^\w\d-]/, '')

    chart_file = File.join( @dataset.root_folder, "dd", "pngs", "#{name}.png")

    if File.file?(chart_file)
      send_file chart_file
    else
      send_file File.join( 'app', 'assets', 'images', 'piechart.png' )
    end
  end

  def files
    file = @dataset.find_file( params[:path] )
    if file and File.file?(file) and @dataset.grants_file_access_to?(current_user)
      @dataset.dataset_file_audits.create( user_id: (current_user ? current_user.id : nil), file_path: @dataset.file_path(file), medium: params[:medium], file_size: File.size(file), remote_ip: request.remote_ip )
      send_file file
    elsif file and File.directory?(file)
      render 'files'
    else
      render nothing: true
    end
  end

  # GET /datasets/1/new_page
  def new_page

  end

  def create_page
    page_name = params[:page_name].to_s.gsub(/[^\w\.\-]/, '').gsub(/^[\.]*/, '')
    @folder_path = @dataset.find_page_folder(params[:path])
    @page_path = File.join(@dataset.pages_folder, @folder_path.to_s, page_name.to_s)
    if not File.exists?(@page_path) and not page_name.blank?
      FileUtils.mkdir_p( File.join(@dataset.pages_folder, @folder_path.to_s) )
      File.open(@page_path, 'w') do |outfile|
        outfile.write params[:page_contents].to_s
      end
      @path = @page_path.gsub(@dataset.pages_folder + '/', '')
      redirect_to pages_dataset_path( @dataset, path: @path )
    else
      @errors = {}
      @errors[:page_name] = page_name.blank? ? "Page name can't be blank" : "A page with that name already exists"
      render 'new_page'
    end
  end

  # GET /datasets/1/edit_page
  def edit_page
    unless @page_path and File.file?(@page_path) and File.size(@page_path) < 1.megabyte
      redirect_to pages_dataset_path(@dataset, path: @path)
    end
  end

  # PATCH /datasets/1/update_page
  def update_page
    if @page_path and File.file?(@page_path) and params.has_key?(:page_contents)
      File.open(@page_path, 'w') do |outfile|
        outfile.write params[:page_contents].to_s
      end
    end

    redirect_to pages_dataset_path( @dataset, path: @path )
  end

  # GET /datasets/1/pages
  def pages
    @term = params[:s].to_s.gsub(/[^\w]/, '')
    @dataset.dataset_page_audits.create( user_id: (current_user ? current_user.id : nil), page_path: @path, remote_ip: request.remote_ip ) if File.file?(@page_path)
  end

  # GET /datasets
  # GET /datasets.json
  def index
    dataset_scope = if current_user
      current_user.all_viewable_datasets
    else
      Dataset.current.where( public: true )
    end
    @datasets = dataset_scope.order('name').page(params[:page]).per( 12 )
  end

  # GET /datasets/1
  # GET /datasets/1.json
  def show
  end

  # GET /datasets/new
  def new
    @dataset = Dataset.new
  end

  # GET /datasets/1/edit
  def edit
  end

  # POST /datasets
  # POST /datasets.json
  def create
    @dataset = current_user.datasets.new(dataset_params)

    respond_to do |format|
      if @dataset.save
        format.html { redirect_to @dataset, notice: 'Dataset was successfully created.' }
        format.json { render action: 'show', status: :created, location: @dataset }
      else
        format.html { render action: 'new' }
        format.json { render json: @dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /datasets/1
  # PATCH/PUT /datasets/1.json
  def update
    respond_to do |format|
      if @dataset.update(dataset_params)
        format.html { redirect_to @dataset, notice: 'Dataset was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @dataset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /datasets/1
  # DELETE /datasets/1.json
  def destroy
    @dataset.destroy
    respond_to do |format|
      format.html { redirect_to datasets_url }
      format.json { head :no_content }
    end
  end

  private
    def set_viewable_dataset
      viewable_datasets = if current_user
        current_user.all_viewable_datasets
      else
        Dataset.current.where( public: true )
      end
      @dataset = viewable_datasets.find_by_slug(params[:id])
    end

    def set_editable_dataset
      @dataset = current_user.all_datasets.find_by_slug(params[:id]) if current_user
    end

    def redirect_without_dataset
      empty_response_or_root_path( datasets_path ) unless @dataset
    end

    def set_page_path
      @page_path = @dataset.find_page(params[:path])
      @path = (@page_path ? @page_path.gsub(@dataset.pages_folder + '/', '') : nil)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dataset_params
      params.require(:dataset).permit(:name, :description, :slug, :logo, :logo_cache, :public, :public_files)
    end

    def site_prefix
      "#{SITE_URL.split('//').first}//#{SITE_URL.split('//').last.split('/').first}"
    end

end
