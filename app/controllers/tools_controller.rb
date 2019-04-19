# frozen_string_literal: true

# Allows users to view to view articles in tools category.
class ToolsController < ApplicationController
  before_action :set_category, only: :index

  # GET /tools
  def index
    scope = Broadcast.current.published.order(publish_date: :desc, id: :desc)
    scope = scope.where(category: @category) if @category
    @articles = scope.page(params[:page]).per(10)
  end

  private

  def set_category
    @category = Category.current.find_by(slug: "tools")
  end
end
