# frozen_string_literal: true

# Allows users to review user-submitted tools.
class ToolReviewsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :find_tool_or_redirect
  before_action :find_existing_tool_review_and_redirect_to_edit, only: [:new, :create]
  before_action :find_tool_review_or_redirect, only: [:edit, :update, :destroy]

  # GET /tools/1/reviews
  def index
    @tool_reviews = @tool.tool_reviews.page(params[:page]).per(40)
  end

  # GET /tools/1/reviews/1
  def show
    @tool_review = @tool.tool_reviews.find_by(id: params[:id])
    redirect_to tool_path(@tool) unless @tool_review
  end

  # GET /tools/1/reviews/new
  def new
    @tool_review = @tool.tool_reviews.new(rating: 3)
  end

  # # GET /tools/1/reviews/1/edit
  # def edit
  # end

  # POST /tools/1/reviews
  def create
    @tool_review = @tool.tool_reviews.where(user_id: current_user.id).new(tool_review_params)
    if @tool_review.save
      @tool_review.create_notification!
      redirect_to tool_tool_reviews_path(@tool), notice: "Review was successfully created."
    else
      render :new
    end
  end

  # PATCH /tools/1/reviews/1
  def update
    if @tool_review.update(tool_review_params)
      @tool_review.create_notification!
      redirect_to tool_tool_reviews_path(@tool), notice: "Review was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /tools/1/reviews/1
  def destroy
    @tool_review.destroy
    redirect_to tool_path(@tool), notice: "Review was successfully deleted."
  end

  private

  def find_tool_or_redirect
    @tool = Tool.current.find_by_param(params[:tool_id])
    redirect_without_tool
  end

  def redirect_without_tool
    empty_response_or_root_path(tools_path) unless @tool
  end

  def find_tool_review
    @tool_review = @tool.tool_reviews.find_by(user_id: current_user.id)
  end

  def find_existing_tool_review_and_redirect_to_edit
    find_tool_review
    redirect_to edit_tool_tool_review_path(@tool, @tool_review) if @tool_review
  end

  def find_tool_review_or_redirect
    find_tool_review
    redirect_without_tool_review
  end

  def redirect_without_tool_review
    empty_response_or_root_path(tool_path(@tool)) unless @tool_review
  end

  def tool_review_params
    params.require(:tool_review).permit(:rating, :review)
  end
end
