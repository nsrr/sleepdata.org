# frozen_string_literal: true

# Allows users to view and create tools.
class ToolsController < ApplicationController
  before_action :find_viewable_tool_or_redirect, only: [:show]

  # GET /tools
  # GET /tools.json
  def index
    scope = tools.search(params[:search])
    if params[:a].present?
      user_ids = User.current.with_name(params[:a].to_s.split(","))
      scope = scope.where(user_id: user_ids.select(:id))
    end
    scope = scope.where(tag_program: true) if params[:type] == "program"
    scope = scope.where(tag_script: true) if params[:type] == "script"
    scope = scope.where(tag_tutorial: true) if params[:type] == "tutorial"
    @tools = scope_order(scope).page(params[:page]).per(20)
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

  def scope_order(scope)
    @order = params[:order]
    scope.order(Arel.sql(Tool::ORDERS[params[:order]] || Tool::DEFAULT_ORDER))
  end
end
