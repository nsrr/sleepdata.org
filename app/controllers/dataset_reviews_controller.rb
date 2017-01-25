# frozen_string_literal: true

# Allows user to review datasets.
class DatasetReviewsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :find_dataset_or_redirect
  before_action :find_existing_dataset_review_and_redirect_to_edit, only: [:new, :create]
  before_action :find_dataset_review_or_redirect, only: [:edit, :update, :destroy]

  # GET /datasets/1/reviews
  def index
    @dataset_reviews = @dataset.dataset_reviews.page(params[:page]).per(40)
  end

  # GET /datasets/1/reviews/1
  def show
    @dataset_review = @dataset.dataset_reviews.find_by_id(params[:id])
    redirect_to @dataset unless @dataset_review
  end

  # GET /datasets/1/reviews/new
  def new
    @dataset_review = @dataset.dataset_reviews.new(rating: 3)
  end

  # GET /datasets/1/reviews/1/edit
  def edit
  end

  # POST /datasets/1/reviews
  def create
    @dataset_review = @dataset.dataset_reviews.where(user_id: current_user.id).new(dataset_review_params)
    if @dataset_review.save
      @dataset_review.create_notification!
      redirect_to dataset_dataset_reviews_path(@dataset), notice: 'Review was successfully created.'
    else
      render :new
    end
  end

  # PATCH /datasets/1/reviews/1
  def update
    if @dataset_review.update(dataset_review_params)
      @dataset_review.create_notification!
      redirect_to dataset_dataset_reviews_path(@dataset), notice: 'Review was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /datasets/1/reviews/1
  def destroy
    @dataset_review.destroy
    redirect_to @dataset, notice: 'Review was successfully deleted.'
  end

  private

  def find_dataset_or_redirect
    @dataset = Dataset.current.find_by_param(params[:dataset_id])
    redirect_without_dataset
  end

  def redirect_without_dataset
    empty_response_or_root_path(tools_path) unless @dataset
  end

  def find_dataset_review
    @dataset_review = @dataset.dataset_reviews.find_by(user_id: current_user.id)
  end

  def find_existing_dataset_review_and_redirect_to_edit
    find_dataset_review
    redirect_to edit_dataset_dataset_review_path(@dataset, @dataset_review) if @dataset_review
  end

  def find_dataset_review_or_redirect
    find_dataset_review
    redirect_without_dataset_review
  end

  def redirect_without_dataset_review
    empty_response_or_root_path(@dataset) unless @dataset_review
  end

  def dataset_review_params
    params.require(:dataset_review).permit(:rating, :review)
  end
end
