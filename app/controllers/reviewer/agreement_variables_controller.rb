# frozen_string_literal: true

# Allows reviewers to specify agreement variables for resubmission.
class Reviewer::AgreementVariablesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_data_request_or_redirect
  before_action :find_agreement_variable_or_redirect, only: [:edit, :update]

  def update
    if @agreement_variable.update(agreement_variable_params)
      respond_to do |format|
        format.html do
          redirect_to review_path(@data_request), notice: "Agreement variable was successfully updated."
        end
        format.js { render :show }
      end
    else
      render :edit
    end
  end

  private

  def find_data_request_or_redirect
    @data_request = current_user.reviewable_data_requests
                                .where(status: "submitted")
                                .find_by(id: params[:data_request_id])
    empty_response_or_root_path(reviews_path) unless @data_request
  end

  def find_agreement_variable_or_redirect
    @agreement_variable = @data_request.agreement_variables.find_by(id: params[:id])
    empty_response_or_root_path(review_path(@data_request)) unless @agreement_variable
  end

  def agreement_variable_params
    params[:agreement_variable] ||= { blank: "1" }
    params[:agreement_variable][:resubmission_required] = params.dig(:agreement_variable, :reviewer_comment).present?
    params.require(:agreement_variable).permit(:reviewer_comment, :resubmission_required)
  end
end
