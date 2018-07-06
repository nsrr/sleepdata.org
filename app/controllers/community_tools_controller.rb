# frozen_string_literal: true

# Allows admins to review community submitted tools.
class CommunityToolsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin
  before_action :set_community_tool, only: [:show, :edit, :update, :destroy]

  # GET /community-tools
  def index
    @order = scrub_order(CommunityTool, params[:order], "community_tools.name")
    @community_tools = CommunityTool.current.order(@order).page(params[:page]).per(40)
  end

  # # GET /community-tools/1
  # def show
  # end

  # GET /community-tools/new
  def new
    @community_tool = CommunityTool.new
  end

  # # GET /community-tools/1/edit
  # def edit
  # end

  # POST /community-tools
  def create
    @community_tool = current_user.community_tools.new(community_tool_params)
    if @community_tool.save
      redirect_to @community_tool, notice: "Community tool was successfully created."
    else
      render :new
    end
  end

  # PATCH /community-tools/1
  def update
    if @community_tool.update(community_tool_params)
      redirect_to @community_tool, notice: "Community tool was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /community-tools/1
  def destroy
    @community_tool.destroy
    redirect_to community_tools_path, notice: "Community tool was successfully deleted."
  end

  private

  def set_community_tool
    @community_tool = CommunityTool.current.find_by_param(params[:id])
  end

  def community_tool_params
    params[:community_tool] ||= { blank: "1" }
    params[:community_tool].delete(:slug) if params[:community_tool][:slug].blank?
    parse_date_if_key_present(:community_tool, :publish_date)
    params.require(:community_tool).permit(
      :name, :url, :description, :slug, :published, :publish_date,
      :tag_program, :tag_script, :tag_tutorial, :series
    )
  end
end
