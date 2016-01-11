class DatasetsController < ApplicationController
  before_action :authenticate_user_from_token!, only: [:json_manifest, :manifest, :files, :refresh_dictionary, :editor, :index, :show]
  before_action :authenticate_user!,        only: [:new, :edit, :create, :update, :destroy, :audits, :collaborators, :create_access, :remove_access, :pull_changes, :sync, :set_public_file, :reset_index]
  before_action :check_system_admin,        only: [:new, :create, :destroy]
  before_action :set_viewable_dataset,      only: [:show, :json_manifest, :manifest, :logo, :images, :files, :access, :pages, :search, :editor]
  before_action :set_editable_dataset,      only: [:edit, :update, :destroy, :audits, :collaborators, :create_access, :remove_access, :pull_changes, :sync, :set_public_file, :reset_index, :refresh_dictionary]
  before_action :redirect_without_dataset,  only: [:show, :json_manifest, :manifest, :logo, :images, :files, :access, :pages, :create_access, :remove_access, :search, :edit, :update, :destroy, :audits, :collaborators, :pull_changes, :sync, :set_public_file, :reset_index, :refresh_dictionary, :editor]

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
                   if pid.nil?
                     # In child
                     # Rails.logger.debug "Refresh Dataset Started"
                     # Rails.logger.debug "Loading Data Dictionary"
                     # @dataset.load_data_dictionary!
                     Rails.logger.debug 'Generating Index for /'
                     @dataset.lock_folder!(nil)
                     @dataset.create_folder_index(nil)
                     Rails.logger.debug 'Generating Index for /datasets'
                     @dataset.lock_folder!('datasets')
                     @dataset.create_folder_index('datasets')
                     Rails.logger.debug 'Refresh Dataset Complete'
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
    user_email = params[:user_email].to_s.strip

    if user = User.current.find_by_email(user_email.split('[').last.to_s.split(']').first)
      @dataset_user = @dataset.dataset_users.where( user_id: user.id, role: params[:role] ).first_or_create
      redirect_to collaborators_dataset_path(@dataset, dataset_user_id: @dataset_user ? @dataset_user.id : nil)
    else
      redirect_to collaborators_dataset_path(@dataset), alert: "User '<code>#{user_email}</code>' was not found."
    end
  end

  def remove_access
    if @dataset_user = @dataset.dataset_users.find_by_id(params[:dataset_user_id])
      @dataset_user.destroy
    end
    redirect_to collaborators_dataset_path(@dataset)
  end

  # GET /datasets/1/file_audits
  def audits
    audit_scope = @dataset.dataset_file_audits.order(created_at: :desc)
    audit_scope = audit_scope.where(user_id: params[:user_id].blank? ? nil : params[:user_id]) if params.key?(:user_id)
    audit_scope = audit_scope.where(medium: params[:medium].blank? ? nil : params[:medium]) if params.key?(:medium)
    audit_scope = audit_scope.where(remote_ip: params[:remote_ip].blank? ? nil : params[:remote_ip]) if params.key?(:remote_ip)
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

  def logo
    send_file File.join( CarrierWave::Uploader::Base.root, @dataset.logo.url )
  end

  def files
    file = @dataset.find_file( params[:path] )
    if file && File.file?(file) && [@dataset.find_file_folder(params[:path]), File.basename(file)].compact.join('/') == params[:path] && (@dataset.public_file?(params[:path]) || @dataset.grants_file_access_to?(current_user))
      @dataset.dataset_file_audits.create(user_id: (current_user ? current_user.id : nil), file_path: @dataset.file_path(file), medium: params[:medium], file_size: File.size(file), remote_ip: request.remote_ip)
      if params[:inline] == '1' && file.to_s.split('.').last.to_s.downcase == 'pdf'
        send_file file, type: 'application/pdf', disposition: 'inline'
      else
        send_file file
      end
    elsif file && File.directory?(file) && @dataset.find_file_folder(params[:path]) == params[:path]
      store_location_in_session
      render 'files'
    elsif !File.directory?(@dataset.files_folder)
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
        if pid.nil?
          # In child
          Rails.logger.debug 'Refresh Folder Index'

          folder_string = File.join('', folder.to_s)

          Rails.logger.debug "Locking #{folder_string}"
          @dataset.lock_folder!(folder)

          Rails.logger.debug "Generating Index for #{folder_string}"
          @dataset.create_folder_index(folder)

          Rails.logger.debug 'Refresh Dataset Folder Complete'

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
    @order = scrub_order(Dataset, params[:order], 'release_date, name')
    dataset_scope = if current_user
                      current_user.all_viewable_datasets
                    else
                      Dataset.current.where(public: true)
                    end
    @datasets = dataset_scope.order(@order).page(params[:page]).per(18)
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

  def dataset_params
    params[:dataset] ||= {}
    params[:dataset][:release_date] = parse_date(params[:dataset][:release_date])
    params.require(:dataset).permit(
      :name, :description, :slug, :logo, :logo_cache, :public,
      :all_files_public, :git_repository, :data_dictionary_repository,
      :release_date, :info_what, :info_who, :info_when, :info_funded_by,
      :info_citation, :info_size
      )
  end
end
