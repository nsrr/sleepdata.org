# frozen_string_literal: true

# Allows modification of comments on during data request review process
class AgreementEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_data_request_or_redirect
  before_action :find_editable_agreement_event_or_redirect, only: [
    :show, :edit, :update, :destroy
  ]

  # # GET /agreement/1/events/1/edit.js
  # def edit
  # end

  # POST /agreement/1/events.js
  def create
    @agreement_event = \
      @data_request.agreement_events
                   .where(user: current_user, event_at: Time.zone.now, event_type: "commented")
                   .new(agreement_event_params)
    if @agreement_event.save
      render :create
    else
      render :new
    end
  end

  # POST /agreements/1/preview.js
  def preview
    @agreement_event = @data_request.agreement_events.find_by(id: params[:agreement_event_id])
    if @agreement_event
      @agreement_event.comment = params[:agreement_event][:comment]
    else
      @agreement_event = @data_request.agreement_events.where(user_id: current_user.id)
                                      .new(agreement_event_params)
    end
  end

  # # GET /agreements/1/events/1.js
  # def show
  # end

  # PATCH /agreement/1/events/1.js
  def update
    if @agreement_event.update(agreement_event_params)
      render :show
    else
      render :edit
    end
  end

  # DELETE /agreement/1/events/1.js
  def destroy
    @agreement_event.destroy
  end

  private

  def find_data_request_or_redirect
    @data_request = current_user.reviewable_data_requests.find_by(id: params[:agreement_id])
    empty_response_or_root_path(reviews_path) unless @data_request
  end

  def find_editable_agreement_event_or_redirect
    @agreement_event = current_user.all_agreement_events.find_by(id: params[:id])
    empty_response_or_root_path(reviews_path) unless @agreement_event
  end

  def agreement_event_params
    params.require(:agreement_event).permit(:comment)
  end
end
