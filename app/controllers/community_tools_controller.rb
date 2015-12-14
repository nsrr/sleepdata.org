class CommunityToolsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin
  before_action :set_community_tool, only: [:show, :edit, :update, :destroy]

  # GET /community-tools
  def index
    @community_tools = CommunityTool.current.page(params[:page]).per(40)
  end

  # GET /community-tools/1
  def show
  end

  # GET /community-tools/new
  def new
    @community_tool = CommunityTool.new
  end

  # GET /community-tools/1/edit
  def edit
  end

  # POST /community-tools
  def create
    @community_tool = current_user.community_tools.new(community_tool_params)
    if @community_tool.save
      redirect_to @community_tool, notice: 'Community tool was successfully created.'
    else
      render :new
    end
  end

  # PATCH /community-tools/1
  def update
    if @community_tool.update(community_tool_params)
      redirect_to @community_tool, notice: 'Community tool was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /community-tools/1
  def destroy
    @community_tool.destroy
    redirect_to community_tools_path, notice: 'Community tool was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_community_tool
    @community_tool = CommunityTool.find_by_id params[:id]
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def community_tool_params
    params.require(:community_tool).permit(:url, :description, :status)
  end
end
