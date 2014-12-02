class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_agreement,                  only: [ :show ]
  before_action :redirect_without_agreement,     only: [ :show ]

  # before_action :set_review, only: [:show, :edit, :update, :destroy]

  def index
    @agreements = current_user.reviewable_agreements # .where( status: ['submitted', 'resubmitted'] )
  end

  def show
  end

  # def new
  #   @review = Review.new
  # end

  # def edit
  # end

  # def create
  #   @review = Review.new(review_params)
  #   @review.save
  # end

  # def update
  #   @review.update(review_params)
  # end

  # def destroy
  #   @review.destroy
  # end

  private
    def set_agreement
      @agreement = current_user.reviewable_agreements.find_by_id(params[:id])
    end

    def redirect_without_agreement
      empty_response_or_root_path( reviews_path ) unless @agreement
    end

    def review_params
      params.require(:review).permit(:agreement_id, :approved)
    end
end
