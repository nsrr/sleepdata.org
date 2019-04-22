# frozen_string_literal: true

# Allows admins to review user-submitted tools.
class Admin::ToolsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin
  before_action :set_tool, only: [:show, :edit, :update, :destroy]

  layout "layouts/full_page_sidebar"

  # GET /admin/tools
  def index
    scope = Tool.current.search(params[:search])
    @tools = scope_order(scope).page(params[:page]).per(40)
  end

  # # GET /admin/tools/1
  # def show
  # end

  # # GET /admin/tools/1/edit
  # def edit
  # end

  # PATCH /admin/tools/1
  def update
    if @tool.update(tool_params)
      redirect_to admin_tool_path(@tool), notice: "Tool was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /admin/tools/1
  def destroy
    @tool.destroy
    redirect_to admin_tools_path, notice: "Tool was successfully deleted."
  end

  private

  def set_tool
    @tool = Tool.current.find_by_param(params[:id])
  end

  def tool_params
    params[:tool] ||= { blank: "1" }
    params[:tool].delete(:slug) if params[:tool][:slug].blank?
    parse_date_if_key_present(:tool, :publish_date)
    params.require(:tool).permit(
      :name, :url, :description, :slug, :published, :publish_date,
      :tag_program, :tag_script, :tag_tutorial, :series
    )
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(Arel.sql(Tool::ORDERS[params[:order]] || Tool::DEFAULT_ORDER))
  end
end
