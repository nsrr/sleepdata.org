# frozen_string_literal: true

# Allows users to view and create tools.
class ToolsController < ApplicationController
  before_action :authenticate_user!, only: [
    :new, :create, :edit, :update, :destroy, :requests, :request_access,
    :set_access, :create_access, :pull_changes, :sync
  ]
  before_action :check_system_admin, only: [:new, :create, :destroy]
  before_action :set_viewable_tool, only: [
    :show, :logo, :images, :pages, :request_access
  ]
  before_action :set_editable_tool, only: [
    :edit, :update, :destroy, :requests, :set_access, :create_access,
    :pull_changes, :sync
  ]
  before_action :redirect_without_tool, only: [
    :show, :logo, :images, :pages, :requests, :request_access, :set_access,
    :create_access, :edit, :update, :destroy, :pull_changes, :sync
  ]

  # Concerns
  include Pageable

  def request_access
    @tool_user = @tool.tool_users.where(user_id: current_user.id).first
    @tool_user = @tool.tool_users.create(user_id: current_user.id, editor: false, approved: nil) unless @tool_user
    redirect_to submissions_path
  end

  def set_access
    @tool_user = @tool.tool_users.find_by_id(params[:tool_user_id])
    @tool_user.update editor: params[:editor], approved: params[:approved] if @tool_user
    redirect_to requests_tool_path(@tool, tool_user_id: @tool_user ? @tool_user.id : nil)
  end

  def create_access
    @tool_user = @tool.tool_users.where(user_id: params[:user_id]).first_or_create
    redirect_to requests_tool_path(@tool, tool_user_id: @tool_user ? @tool_user.id : nil)
  end

  # GET /tools
  # GET /tools.json
  def index
    tool_scope = if current_user
                   current_user.all_viewable_tools
                 else
                   Tool.current.where(public: true)
                 end

    # tool_scope = tool_scope.where(tool_type: params[:type]) unless params[:type].blank?
    @tools = tool_scope.order(:tool_type, :name).page(params[:page]).per(12)

    @order = scrub_order(CommunityTool, params[:order], "community_tools.name")
    community_tool_scope = CommunityTool.current.order(@order).where(published: true)
    unless params[:a].blank?
      user_ids = User.current.with_name(params[:a].to_s.split(","))
      community_tool_scope = community_tool_scope.where(user_id: user_ids.select(:id))
    end

    community_tool_scope = community_tool_scope.where(tag_program: true) if params[:type] == "program"
    community_tool_scope = community_tool_scope.where(tag_script: true) if params[:type] == "script"
    community_tool_scope = community_tool_scope.where(tag_tutorial: true) if params[:type] == "tutorial"
    @community_tools = community_tool_scope.search(params[:search]).page(params[:page]).per(20)
  end

  # GET /tools/1
  # GET /tools/1.json
  def show
  end

  # GET /community/tools/1
  def community_show
    @community_tool = CommunityTool.current.where(published: true).find_by_param(params[:id])
    empty_response_or_root_path(tools_path) unless @community_tool
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
        format.html { redirect_to @tool, notice: "Tool was successfully created." }
        format.json { render :show, status: :created, location: @tool }
      else
        format.html { render :new }
        format.json { render json: @tool.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tools/1
  # PUT /tools/1.json
  def update
    respond_to do |format|
      if @tool.update(tool_params)
        format.html { redirect_to @tool, notice: "Tool was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render :edit }
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
    send_file_if_present @tool.logo
  end

  private

  def set_viewable_tool
    viewable_tools = if current_user
                       current_user.all_viewable_tools
                     else
                       Tool.current.where(public: true)
                     end
    @tool = viewable_tools.find_by(slug: params[:id])
  end

  def set_editable_tool
    @tool = current_user.all_tools.find_by(slug: params[:id]) if current_user
  end

  def redirect_without_tool
    empty_response_or_root_path(tools_path) unless @tool
  end

  def tool_params
    params.require(:tool).permit(
      :name, :description, :slug, :logo, :logo_cache, :public, :tool_type,
      :git_repository
    )
  end
end
