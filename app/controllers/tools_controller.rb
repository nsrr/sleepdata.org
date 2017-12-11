# frozen_string_literal: true

# Allows users to view and create tools.
class ToolsController < ApplicationController
  before_action :find_viewable_tool_or_redirect, only: [:show]

  # GET /tools
  # GET /tools.json
  def index
    @order = scrub_order(CommunityTool, params[:order], "community_tools.name")
    if @order == "community_tools.name"
      community_tool_scope = community_tools.order(Arel.sql("LOWER(community_tools.name)"))
    elsif @order == "community_tools.name desc nulls last"
      community_tool_scope = community_tools.order(Arel.sql("LOWER(community_tools.name) desc nulls last"))
    else
      community_tool_scope = community_tools.order(@order)
    end
    if params[:a].present?
      user_ids = User.current.with_name(params[:a].to_s.split(","))
      community_tool_scope = community_tool_scope.where(user_id: user_ids.select(:id))
    end
    community_tool_scope = community_tool_scope.where(tag_program: true) if params[:type] == "program"
    community_tool_scope = community_tool_scope.where(tag_script: true) if params[:type] == "script"
    community_tool_scope = community_tool_scope.where(tag_tutorial: true) if params[:type] == "tutorial"
    @community_tools = community_tool_scope.search(params[:search]).page(params[:page]).per(20)
  end

  # # GET /tools/1
  # # GET /tools/1.json
  # def show
  # end

  private

  def community_tools
    CommunityTool.published_or_draft(current_user)
  end

  def find_viewable_tool_or_redirect
    @community_tool = community_tools.find_by_param(params[:id])
    empty_response_or_root_path(tools_path) unless @community_tool
  end
end
