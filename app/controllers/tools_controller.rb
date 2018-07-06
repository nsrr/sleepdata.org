# frozen_string_literal: true

# Allows users to view and create tools.
class ToolsController < ApplicationController
  before_action :find_viewable_tool_or_redirect, only: [:show]

  # GET /tools
  # GET /tools.json
  def index
    @order = scrub_order(Tool, params[:order], "tools.name")
    if @order == "tools.name"
      tool_scope = tools.order(Arel.sql("LOWER(tools.name)"))
    elsif @order == "tools.name desc nulls last"
      tool_scope = tools.order(Arel.sql("LOWER(tools.name) desc nulls last"))
    else
      tool_scope = tools.order(@order)
    end
    if params[:a].present?
      user_ids = User.current.with_name(params[:a].to_s.split(","))
      tool_scope = tool_scope.where(user_id: user_ids.select(:id))
    end
    tool_scope = tool_scope.where(tag_program: true) if params[:type] == "program"
    tool_scope = tool_scope.where(tag_script: true) if params[:type] == "script"
    tool_scope = tool_scope.where(tag_tutorial: true) if params[:type] == "tutorial"
    @tools = tool_scope.search(params[:search]).page(params[:page]).per(20)
  end

  # # GET /tools/1
  # # GET /tools/1.json
  # def show
  # end

  private

  def tools
    Tool.published_or_draft(current_user)
  end

  def find_viewable_tool_or_redirect
    @tool = tools.find_by_param(params[:id])
    empty_response_or_root_path(tools_path) unless @tool
  end
end
