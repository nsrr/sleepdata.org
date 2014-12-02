class DatasetsController < ApplicationController
  before_action :authenticate_user_from_token!, only: [ :json_manifest, :manifest, :files, :upload_graph, :refresh_dictionary, :upload_dataset_csv, :editor ]
  before_action :authenticate_user!,        only: [ :new, :edit, :create, :update, :destroy, :audits, :requests, :create_access, :remove_access, :new_page, :create_page, :edit_page, :update_page, :pull_changes, :sync, :set_public_file, :reset_index ]
  before_action :check_system_admin,        only: [ :new, :create, :destroy, :pull_changes, :sync ]
  before_action :set_viewable_dataset,      only: [ :show, :json_manifest, :manifest, :logo, :images, :files, :access, :pages, :search, :editor ]
  before_action :set_editable_dataset,      only: [ :edit, :update, :destroy, :audits, :requests, :create_access, :remove_access, :new_page, :create_page, :edit_page, :update_page, :pull_changes, :sync, :set_public_file, :reset_index, :upload_graph, :refresh_dictionary, :upload_dataset_csv ]
  before_action :redirect_without_dataset,  only: [ :show, :json_manifest, :manifest, :logo, :images, :files, :access, :pages, :create_access, :remove_access, :search, :edit, :update, :destroy, :audits, :requests, :new_page, :create_page, :edit_page, :update_page, :pull_changes, :sync, :set_public_file, :reset_index, :upload_graph, :refresh_dictionary, :upload_dataset_csv, :editor ]

  skip_before_action :verify_authenticity_token, only: [ :upload_graph, :upload_dataset_csv ]

  # Concerns
  include Pageable

  # Returns if the user is an editor
  def editor
    editor = (current_user && @dataset.editable_by?(current_user) ? true : false)
    render json: { editor: editor, user_id: (current_user ? current_user.id : nil) }
  end

  def refresh_dictionary
    version = params[:version].to_s.gsub(/[^a-z\.\d]/, '')
    stdout = @dataset.pull_new_data_dictionary!(version)
    response = if stdout.match(/Switched to a new branch '#{version}'/)
      unless Rails.env.test?
        pid = Process.fork
        if pid.nil? then
          # In child
          Rails.logger.debug "Refresh Dataset Started"
          Rails.logger.debug "Loading Data Dictionary"
          @dataset.load_data_dictionary!

          Rails.logger.debug "Generating Index for /"
          @dataset.lock_folder!(nil)
          @dataset.create_folder_index(nil)

          Rails.logger.debug "Generating Index for /datasets"
          @dataset.lock_folder!('datasets')
          @dataset.create_folder_index('datasets')

          Rails.logger.debug "Refresh Dataset Complete"

          Kernel.exit!
        else
          # In parent
          Process.detach(pid)
        end
      end
      'success'
    elsif stdout.match(/DD Git Repository Does Not Exist/)
      'gitrepodoesnotexist'
    else
      'notagfound'
    end

    render json: { refresh: response }
  end

  def upload_dataset_csv
    upload = 'success'
    dataset_csv_folder = File.join(@dataset.files_folder, 'datasets')
    FileUtils.mkpath dataset_csv_folder
    new_file_location = ''
    begin
      if params[:file]
        new_file_location = File.join(dataset_csv_folder, params[:file].original_filename)
        FileUtils.cp params[:file].tempfile, new_file_location
      end
    rescue
    end

    if not File.exist?(new_file_location) or (File.exist?(new_file_location) and File.size(new_file_location) == 0)
      upload = 'failed'
    end

    render json: { upload: upload }
  end

  def upload_graph
    upload = 'success'
    version = params[:version].to_s.gsub(/[^a-z\.\d]/, '')
    type = params[:type] == 'images' ? 'images' : 'graphs'
    version_folder = File.join(@dataset.data_dictionary_folder, type, version)
    FileUtils.mkpath version_folder

    new_file_location = ''
    begin
      if params[:file]
        new_file_location = File.join(version_folder, params[:file].original_filename)
        FileUtils.cp params[:file].tempfile, new_file_location
      end
    rescue
    end

    if not File.exist?(new_file_location) or (File.exist?(new_file_location) and File.size(new_file_location) == 0)
      upload = 'failed'
    end

    render json: { upload: upload }
  end

  def set_public_file
    file = @dataset.find_file( params[:path] )
    if file
      if params[:public] == '1'
        @dataset.public_files.where( file_path: @dataset.file_path(file) ).first_or_create( user_id: current_user.id )
      else
        @dataset.public_files.where( file_path: @dataset.file_path(file) ).destroy_all
      end
    end

    redirect_to files_dataset_path(@dataset, path: @dataset.find_file_folder(params[:path]))
  end

  def create_access
    @dataset_user = @dataset.dataset_users.where( user_id: params[:user_id], role: params[:role] ).first_or_create
    redirect_to requests_dataset_path(@dataset, dataset_user_id: @dataset_user ? @dataset_user.id : nil)
  end

  def remove_access
    if @dataset_user = @dataset.dataset_users.find_by_id(params[:dataset_user_id])
      @dataset_user.destroy
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

  # GET /datasets/1/json_manifest
  def json_manifest
    @folder_path = @dataset.find_file_folder(params[:path])
    if @folder_path == params[:path]
      render json: @dataset.indexed_files(@folder_path, -1).collect{ |folder, file_name, is_file, file_size, file_time, file_checksum| { file_name: file_name, checksum: file_checksum, is_file: is_file, file_size: file_size, dataset: @dataset.slug, file_path: folder } }
    else
      render json: []
    end
  end

  # GET /datasets/1/manifest.txt
  def manifest
    @folder_path = @dataset.find_file_folder(params[:path])
    render text: @dataset.indexed_files(@folder_path, -1).select{|folder, file_name, is_file, file_size, file_time, file_checksum| is_file}.collect{|folder, file_name, is_file, file_size, file_time, file_checksum| site_prefix + files_dataset_path(@dataset, path: folder, auth_token: (current_user ? current_user.id_and_auth_token : nil ), medium: 'wget')}.join("\n\r")
  end

  def logo
    send_file File.join( CarrierWave::Uploader::Base.root, @dataset.logo.url )
  end

  def files
    file = @dataset.find_file( params[:path] )
    if file and File.file?(file) and [@dataset.find_file_folder(params[:path]), File.basename(file)].compact.join('/') == params[:path] and (@dataset.public_file?(params[:path]) or @dataset.grants_file_access_to?(current_user))
      @dataset.dataset_file_audits.create( user_id: (current_user ? current_user.id : nil), file_path: @dataset.file_path(file), medium: params[:medium], file_size: File.size(file), remote_ip: request.remote_ip )
      send_file file
    elsif file and File.directory?(file) and @dataset.find_file_folder(params[:path]) == params[:path]
      store_location_in_session
      render 'files'
    elsif not File.directory?(@dataset.files_folder)
      redirect_to @dataset
    else
      redirect_to files_dataset_path(@dataset, path: @dataset.find_file_folder(params[:path]))
    end
  end

  # Get /datasets/access/*path
  def access
    file = @dataset.find_file( params[:path] )
    if file and File.file?(file) and [@dataset.find_file_folder(params[:path]), File.basename(file)].compact.join('/') == params[:path] and (@dataset.public_file?(params[:path]) or @dataset.grants_file_access_to?(current_user))
      render json: { dataset_id: @dataset.id, result: true, path: [@dataset.find_file_folder(params[:path]), File.basename(file)].compact.join('/') }
    else
      render json: { dataset_id: @dataset.id, result: false, path: [@dataset.find_file_folder(params[:path]), File.basename(file)].compact.join('/') }
    end
  end

  def reset_index
    file = @dataset.find_file( params[:path] )
    folder = @dataset.find_file_folder(params[:path])
    if file and File.directory?(file) and not @dataset.current_folder_locked?(folder)
      unless Rails.env.test?
        pid = Process.fork
        if pid.nil? then
          # In child
          Rails.logger.debug "Refresh Folder Index"

          Rails.logger.debug "Locking Folder #{File.join('', folder)}"
          @dataset.lock_folder!(folder)

          Rails.logger.debug "Generating Index for #{File.join('', folder)}"
          @dataset.create_folder_index(folder)

          Rails.logger.debug "Refresh Dataset Folder Complete"

          Kernel.exit!
        else
          # In parent
          Process.detach(pid)
        end
      end
    end
    redirect_to files_dataset_path(@dataset, path: @dataset.find_file_folder(params[:path]))
  end

  # GET /datasets
  # GET /datasets.json
  def index
    dataset_scope = if current_user
      current_user.all_viewable_datasets
    else
      Dataset.current.where( public: true )
    end
    @datasets = dataset_scope.order(:release_date, :name).page(params[:page]).per( 18 )
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
      super(:id)
    end

    def set_editable_dataset
      super(:id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dataset_params
      params[:dataset] ||= {}
      params[:dataset][:release_date] = parse_date(params[:dataset][:release_date])
      params.require(:dataset).permit( :name, :description, :slug, :logo, :logo_cache, :public, :all_files_public, :git_repository, :release_date )
    end

    def site_prefix
      "#{SITE_URL.split('//').first}//#{SITE_URL.split('//').last.split('/').first}"
    end

end
