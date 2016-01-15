# Allows modification of comments on during agreement review process
class AgreementEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_agreement
  before_action :set_editable_agreement_event, only: [:show, :edit, :update, :destroy]

  # GET /agreement/1/agreement_events/1/edit.js
  def edit
  end

  # POST /agreement/1/agreement_events
  # POST /agreement/1/agreement_events.js
  def create
    @agreement_event = @agreement.agreement_events.where(user_id: current_user.id, event_at: Time.zone.now, event_type: 'commented').new(agreement_event_params)

    respond_to do |format|
      if @agreement_event.save
        format.html { redirect_to review_path(@agreement) + "#c#{@agreement_event.number}", notice: 'Review was successfully created.' }
        # redirect_to topic_comment_path(@topic, @comment), notice: 'Comment was successfully created.'
        format.js { render :create }
      else
        format.html { redirect_to review_path(@agreement) + "#c#{@agreement.agreement_events.count}" }
        # redirect_to topic_path(@topic, error: @errors)
        format.js { render :new }
      end
    end
  end

  def preview
    @agreement_event = @agreement.agreement_events.find_by_id params[:agreement_event_id]
    if @agreement_event
      @agreement_event.comment = params[:agreement_event][:comment]
    else
      @agreement_event = @agreement.agreement_events.where(user_id: current_user.id).new(agreement_event_params)
    end
  end

  def show
    respond_to do |format|
      format.html { redirect_to topic_path(@topic) + "?page=#{((@comment.number - 1) / Comment::COMMENTS_PER_PAGE)+1}#c#{@comment.number}" }
      format.js
    end
  end

  # def show
  # end

  # PATCH /agreement/1/agreement_events/1
  # PATCH /agreement/1/agreement_events/1.js
  def update
    respond_to do |format|
      if @agreement_event.update(agreement_event_params)
        format.html { redirect_to review_path(@agreement) + "#c#{@agreement_event.number}", notice: 'Comment was successfully updated.' }
        format.js { render :show }
      else
        format.html { redirect_to review_path(@agreement) + "#c#{@agreement_event.number}", warning: 'Comment can\'t be blank.' }
        format.js { render :edit }
      end
    end
  end

  # DELETE /agreement/1/agreement_events/1
  def destroy
    @comment.destroy

    redirect_to topic_comment_path(@topic, @comment)
  end

  private

  def set_agreement
    @agreement = current_user.reviewable_agreements.find_by_id(params[:agreement_id])
    empty_response_or_root_path(reviews_path) unless @agreement
  end

  def set_editable_agreement_event
    @agreement_event = current_user.all_agreement_events.find_by_id(params[:id])
    empty_response_or_root_path(reviews_path) unless @agreement_event
  end

  def agreement_event_params
    params.require(:agreement_event).permit(:comment)
  end
end
