class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_agreement,                  only: [ :show, :create_comment, :preview, :show_comment, :edit_comment, :update_comment, :destroy_comment ]
  before_action :redirect_without_agreement,     only: [ :show, :create_comment, :preview, :show_comment, :edit_comment, :update_comment, :destroy_comment ]

  before_action :set_editable_agreement_event,      only: [ :show_comment, :edit_comment, :update_comment, :destroy_comment ]
  before_action :redirect_without_agreement_event,  only: [ :show_comment, :edit_comment, :update_comment, :destroy_comment ]

  def index
    params[:order] = "agreements.last_submitted_at DESC" if params[:order].blank?
    @order = scrub_order(Agreement, params[:order], [:id])
    agreement_scope = current_user.reviewable_agreements.search(params[:search]).order(@order)
    agreement_scope = agreement_scope.where( status: params[:status] ) if params[:status].present?
    @agreements = agreement_scope.page(params[:page]).per( 40 )
  end

  def show
  end

  # def new
  #   @review = Review.new
  # end

  # def edit
  # end

  def preview
    @agreement_event = @agreement.agreement_events.new(agreement_event_params)
  end

  def create_comment
    @agreement_event = @agreement.agreement_events.where(user_id: current_user.id, event_at: Time.now, event_type: 'commented').new(agreement_event_params)

    respond_to do |format|
      if @agreement_event.save
        format.html { redirect_to review_path(@agreement) + "#c#{@agreement_event.number}", notice: 'Review was successfully created.' }
        format.json { render action: 'show', status: :created, location: @agreement_event }
      else
        format.html { render action: 'new' }
        format.json { render json: @agreement_event.errors, status: :unprocessable_entity }
      end
    end
  end

  def show_comment
  end

  def edit_comment
  end

  def update_comment
    respond_to do |format|
      if @agreement_event.update(agreement_event_params)
        format.html { redirect_to review_path(@agreement) + "#c#{@agreement_event.number}", notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to review_path(@agreement) + "#c#{@agreement_event.number}", warning: 'Comment can\'t be blank.' }
        format.json { render json: @agreement_event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy_comment
    @agreement_event.destroy

    respond_to do |format|
      format.html { redirect_to review_path(@agreement) + "#c#{@agreement_event.number}" }
      format.json { head :no_content }
    end
  end

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

    def set_editable_agreement_event
      @agreement_event = current_user.all_agreement_events.find_by_id(params[:agreement_event_id])
    end

    def redirect_without_agreement_event
      empty_response_or_root_path( reviews_path ) unless @agreement_event
    end

    def agreement_event_params
      params.require(:agreement_event).permit(:comment)
    end
end
