class DatasetsController < ApplicationController
  before_action :authenticate_user_from_token!, only: [ :manifest, :files ]
  before_action :authenticate_user!,        only: [ :new, :edit, :create, :update, :destroy, :audits, :requests, :request_access, :set_access, :create_access, :new_page, :create_page, :edit_page, :update_page, :pull_changes, :sync ]
  before_action :check_system_admin,        only: [ :new, :create, :destroy, :pull_changes, :sync ]
  before_action :set_viewable_dataset,      only: [ :show, :manifest, :logo, :images, :files, :pages, :request_access, :search ]
  before_action :set_editable_dataset,      only: [ :edit, :update, :destroy, :audits, :requests, :set_access, :create_access, :new_page, :create_page, :edit_page, :update_page, :pull_changes, :sync ]
  before_action :redirect_without_dataset,  only: [ :show, :manifest, :logo, :images, :files, :pages, :request_access, :set_access, :create_access, :search, :edit, :update, :destroy, :audits, :requests, :new_page, :create_page, :edit_page, :update_page, :pull_changes, :sync ]

  # Concerns
  include Pageable

  def request_access
    if @dataset_user = @dataset.dataset_users.where( user_id: current_user.id ).first
      # Dataset access has already been requested
    else
      @dataset_user = @dataset.dataset_users.create( user_id: current_user.id, editor: false, approved: nil )
      @dataset.editors.each do |editor|
        UserMailer.dataset_access_requested(@dataset_user, editor).deliver if Rails.env.production?
      end
    end
    if params[:path]
      redirect_to files_dataset_path(@dataset, path: params[:path])
    else
      redirect_to daua_path
    end
  end

  def set_access
    if @dataset_user = @dataset.dataset_users.find_by_id(params[:dataset_user_id])
      @dataset_user.update( editor: params[:editor], approved: params[:approved] )
      if @dataset_user.approved? and not @dataset_user.email_sent?
        UserMailer.dataset_access_approved(@dataset_user, current_user).deliver if Rails.env.production?
        @dataset_user.update email_sent: true
      end
    end
    redirect_to requests_dataset_path(@dataset, dataset_user_id: @dataset_user ? @dataset_user.id : nil)
  end

  def create_access
    @dataset_user = @dataset.dataset_users.where( user_id: params[:user_id] ).first_or_create
    redirect_to requests_dataset_path(@dataset, dataset_user_id: @dataset_user ? @dataset_user.id : nil)
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
    render text: @dataset.indexed_files(@folder_path, -1).select{|folder, file_name, is_file, file_size, file_time| is_file}.collect{|folder, file_name, is_file, file_size, file_time| site_prefix + files_dataset_path(@dataset, path: folder, auth_token: (current_user ? current_user.id_and_auth_token : nil ), medium: 'wget')}.join("\n\r")
  end

  def logo
    send_file File.join( CarrierWave::Uploader::Base.root, @dataset.logo.url )
  end

  def files
    file = @dataset.find_file( params[:path] )
    if file and File.file?(file) and [@dataset.find_file_folder(params[:path]), File.basename(file)].compact.join('/') == params[:path] and @dataset.grants_file_access_to?(current_user)
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

  # GET /datasets
  # GET /datasets.json
  def index
    dataset_scope = if current_user
      current_user.all_viewable_datasets
    else
      Dataset.current.where( public: true )
    end
    @datasets = dataset_scope.order(:release_date, :name).page(params[:page]).per( 12 )
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
      params.require(:dataset).permit( :name, :description, :slug, :logo, :logo_cache, :public, :public_files, :git_repository, :release_date )
    end

    def site_prefix
      "#{SITE_URL.split('//').first}//#{SITE_URL.split('//').last.split('/').first}"
    end

end
