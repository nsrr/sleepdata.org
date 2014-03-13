class ToolsController < ApplicationController
  before_action :authenticate_user!,        only: [ :new, :create, :edit, :update, :destroy, :new_page, :create_page, :edit_page, :update_page, :pull_changes, :sync ]
  before_action :check_system_admin,        only: [ :new, :create, :destroy, :pull_changes, :sync ]
  before_action :set_viewable_tool,         only: [ :show, :logo, :images, :pages ]
  before_action :set_editable_tool,         only: [ :edit, :update, :destroy, :new_page, :create_page, :edit_page, :update_page, :pull_changes, :sync ]
  before_action :redirect_without_tool,     only: [ :show, :logo, :images, :pages, :edit, :update, :destroy, :new_page, :create_page, :edit_page, :update_page, :pull_changes, :sync ]

  # Concerns
  include Pageable

  # GET /tools
  # GET /tools.json
  def index
    tool_scope = Tool.current
    tool_scope = tool_scope.where( tool_type: params[:type] ) unless params[:type].blank?
    tool_scope = tool_scope.where( author: params[:author] ) unless params[:author].blank?
    @tools = tool_scope.order(:tool_type, :name).page(params[:page]).per( 12 )
  end

  # GET /tools/1
  # GET /tools/1.json
  def show
  end

  # GET /tools/new
  def new
    @tool = Tool.new
  end

  # GET /tools/1/edit
  def edit
  end

  # POST /tools
  # POST /tools.json
  def create
    @tool = current_user.tools.new(tool_params)

    respond_to do |format|
      if @tool.save
        format.html { redirect_to @tool, notice: 'Tool was successfully created.' }
        format.json { render action: 'show', status: :created, location: @tool }
      else
        format.html { render action: 'new' }
        format.json { render json: @tool.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tools/1
  # PUT /tools/1.json
  def update
    respond_to do |format|
      if @tool.update(tool_params)
        format.html { redirect_to @tool, notice: 'Tool was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @tool.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tools/1
  # DELETE /tools/1.json
  def destroy
    @tool.destroy

    respond_to do |format|
      format.html { redirect_to tools_path }
      format.json { head :no_content }
    end
  end

  def logo
    send_file File.join( CarrierWave::Uploader::Base.root, @tool.logo.url )
  end

  private
    def set_viewable_tool
      @tool = Tool.current.find_by_slug( params[:id] )
    end

    def set_editable_tool
      @tool = current_user.all_tools.find_by_slug( params[:id] ) if current_user
    end

    def redirect_without_tool
      empty_response_or_root_path( tools_path ) unless @tool
    end

    def tool_params
      params.require(:tool).permit( :name, :author, :description, :slug, :logo, :logo_cache, :tool_type, :git_repository )
    end
end
