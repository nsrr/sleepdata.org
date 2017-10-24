# frozen_string_literal: true

# Allows user to review community tools.
class CommunityToolReviewsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :find_community_tool_or_redirect
  before_action :find_existing_community_tool_review_and_redirect_to_edit, only: [:new, :create]
  before_action :find_community_tool_review_or_redirect, only: [:edit, :update, :destroy]

  # GET /community_tools/1/reviews
  def index
    @community_tool_reviews = @community_tool.community_tool_reviews.page(params[:page]).per(40)
  end

  # GET /community_tools/1/reviews/1
  def show
    @community_tool_review = @community_tool.community_tool_reviews.find_by_id(params[:id])
    redirect_to tool_path(@community_tool) unless @community_tool_review
  end

  # GET /community_tools/1/reviews/new
  def new
    @community_tool_review = @community_tool.community_tool_reviews.new(rating: 3)
  end

  # GET /community_tools/1/reviews/1/edit
  def edit
  end

  # POST /community_tools/1/reviews
  def create
    @community_tool_review = @community_tool.community_tool_reviews.where(user_id: current_user.id).new(community_tool_review_params)
    if @community_tool_review.save
      @community_tool_review.create_notification!
      redirect_to community_tool_community_tool_reviews_path(@community_tool), notice: 'Review was successfully created.'
    else
      render :new
    end
  end

  # PATCH /community_tools/1/reviews/1
  def update
    if @community_tool_review.update(community_tool_review_params)
      @community_tool_review.create_notification!
      redirect_to community_tool_community_tool_reviews_path(@community_tool), notice: 'Review was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /community_tools/1/reviews/1
  def destroy
    @community_tool_review.destroy
    redirect_to tool_path(@community_tool), notice: 'Review was successfully deleted.'
  end

  private

  def find_community_tool_or_redirect
    @community_tool = CommunityTool.current.find_by_param(params[:community_tool_id])
    redirect_without_community_tool
  end

  def redirect_without_community_tool
    empty_response_or_root_path(tools_path) unless @community_tool
  end

  def find_community_tool_review
    @community_tool_review = @community_tool.community_tool_reviews.find_by(user_id: current_user.id)
  end

  def find_existing_community_tool_review_and_redirect_to_edit
    find_community_tool_review
    redirect_to edit_community_tool_community_tool_review_path(@community_tool, @community_tool_review) if @community_tool_review
  end

  def find_community_tool_review_or_redirect
    find_community_tool_review
    redirect_without_community_tool_review
  end

  def redirect_without_community_tool_review
    empty_response_or_root_path(tool_path(@community_tool)) unless @community_tool_review
  end

  def community_tool_review_params
    params.require(:community_tool_review).permit(:rating, :review)
  end
end
