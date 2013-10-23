class DatasetsController < ApplicationController
  before_action :authenticate_user!,        only: [ :new, :edit, :create, :update, :destroy ]
  before_action :check_system_admin,        only: [ :new, :edit, :create, :update, :destroy ]
  before_action :set_viewable_dataset,      only: [ :show, :manifest, :logo, :files ]
  before_action :set_editable_dataset,      only: [ :edit, :update, :destroy ]
  before_action :redirect_without_dataset,  only: [ :show, :manifest, :logo, :files, :edit, :update, :destroy ]

  # GET /datasets/1/manifest.txt
  def manifest
     render text: @dataset.files.collect{|name, f| site_prefix + files_dataset_path(@dataset, basename: name.split('.')[0..-2].join('.'), extension: name.split('.').last, auth_token: (current_user ? current_user.authentication_token : nil ))}.join("\n\r")
  end

  def logo
    send_file File.join( Rails.root, 'carrierwave', @dataset.logo.url )
  end

  def files
    # current_user ? current_user.usage += file.size
    filename = "#{params[:basename].to_s.strip}.#{params[:extension].to_s.strip}".gsub(/[^\w\-\.]/, '')
    file = File.join( Rails.root, 'carrierwave', 'datasets', 'files', @dataset.id.to_s, filename )
    if File.exists?(file)
      send_file file
    else
      render nothing: true
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def dataset_params
      params.require(:dataset).permit(:name, :description, :slug, :logo, :logo_cache, :public)
    end

    def site_prefix
      "#{SITE_URL.split('//').first}//#{SITE_URL.split('//').last.split('/').first}"
    end

end
