# frozen_string_literal: true

# Allows reviewers to view data requests.
class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_data_request_or_redirect, only: [
    :show, :print, :transactions, :vote, :update_tags, :autocomplete,
    :signature, :duly_authorized_representative_signature, :reviewer_signature,
    :reset_signature
  ]

  # GET /reviews
  def index
    scope = current_user.reviewable_data_requests.advanced_search(Arel.sql(params[:search].to_s))
    scope = scope.without_vote(current_user) if params[:voted].to_s == "0"
    scope = scope.with_vote(current_user) if params[:voted].to_s == "1"
    scope = scope.with_tag(params[:tag_id]) if params[:tag_id].present?
    scope = scope.where(status: params[:status]) if params[:status].present?
    @data_requests = scope_order(scope).page(params[:page]).per(10)
    render layout: "layouts/full_page_sidebar"
  end

  # # GET /reviews/1
  # def show
  # end

  # GET /reviews/1/print
  def print
    @data_request.generate_printed_pdf!
    if @data_request.printed_file.present?
      send_file @data_request.printed_file.path, filename: "#{@data_request.user.full_name.gsub(/[^a-zA-Z\p{L}]/, "")}-#{@data_request.agreement_number}-data-request-#{(@data_request.submitted_at || @data_request.created_at).strftime("%Y-%m-%d")}.pdf", type: "application/pdf", disposition: "inline"
    else
      render "data_requests/print", layout: false
    end
  end

  # GET /reviews/1/signature
  def signature
    send_file_if_present @data_request.signature_file
  end

  # GET /reviews/1/duly_authorized_representative_signature
  def duly_authorized_representative_signature
    send_file_if_present @data_request.duly_authorized_representative_signature_file
  end

  # GET /reviews/1/reviewer_signature
  def reviewer_signature
    send_file_if_present @data_request.reviewer_signature_file
  end

  # # GET /reviews/1/transactions
  # def transactions
  # end

  # POST /reviews/1/vote.js
  def vote
    @data_request_review = @data_request.data_request_reviews.where(user: current_user).first_or_create
    original_approval = @data_request_review.approved
    original_vote_cleared = @data_request_review.vote_cleared?
    @data_request_review.update(approved: (params[:approved].to_s == "1"), vote_cleared: false) if params.key?(:approved)
    event_type = \
      if @data_request_review.approved == original_approval && !original_vote_cleared
        ""
      elsif @data_request_review.approved == true && original_approval == false
        "reviewer_changed_from_rejected_to_approved"
      elsif @data_request_review.approved == false && original_approval == true
        "reviewer_changed_from_approved_to_rejected"
      elsif original_vote_cleared && @data_request_review.approved == true
        "reviewer_reapproved"
      elsif original_vote_cleared && @data_request_review.approved == false
        "reviewer_rerejected"
      elsif @data_request_review.approved == true
        "reviewer_approved"
      elsif @data_request_review.approved == false
        "reviewer_rejected"
      end
    @data_request.agreement_events.create(event_type: "commented", user: current_user, event_at: Time.zone.now, comment: params[:comment]) if params[:comment].present?
    @agreement_event = @data_request.agreement_events.create(event_type: event_type, user: current_user, event_at: Time.zone.now) if event_type.present?
  end

  # POST /reviews/1/update_tags.js
  def update_tags
    submitted_tags = Tag.review_tags.where(id: params[:data_request][:tag_ids])
    added_removed_tag_ids = []
    Tag.review_tags.each do |tag|
      if submitted_tags.include?(tag) && !@data_request.tags.include?(tag)
        added_removed_tag_ids << [tag.id, true]
      elsif !submitted_tags.include?(tag) && @data_request.tags.include?(tag)
        added_removed_tag_ids << [tag.id, false]
      end
    end
    if added_removed_tag_ids.count > 0
      @data_request.update tags: submitted_tags
      @agreement_event = @data_request.agreement_events.create event_type: "tags_updated", user_id: current_user.id, event_at: Time.zone.now
      added_removed_tag_ids.each do |tag_id, added|
        @agreement_event.agreement_event_tags.create tag_id: tag_id, added: added
      end
    end
    render "agreement_events/index"
  end

  # GET /reviews/1/autocomplete.json
  def autocomplete
    user_scope = \
      User
      .current.where("username ILIKE (?)", "#{params[:q]}%")
      .where(id: @data_request.data_request_reviews.select(:user_id))
      .order(:username).limit(10)
    render json: user_scope.pluck(:username)
  end

  # DELETE /reviews/1/reset-signature
  def reset_signature
    if @data_request.submitted?
      @data_request.reset_signature_fields!(current_user)
      flash[:notice] = "Signature field reset successfully."
    end
    redirect_to review_path(@data_request)
  end

  private

  def find_data_request_or_redirect
    @data_request = current_user.reviewable_data_requests.find_by(id: params[:id])
    empty_response_or_root_path(reviews_path) unless @data_request
  end

  def scope_order(scope)
    @order = params[:order]
    scope.order(Arel.sql(DataRequest::ORDERS[params[:order]] || DataRequest::DEFAULT_ORDER))
  end
end
