# frozen_string_literal: true

# Provides common methods used by all API controllers.
class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user_from_token!
  before_action :authenticate_user!
  before_action :set_dataset
  skip_before_action :verify_authenticity_token

  private

  def set_dataset
    @dataset = current_user.all_datasets.find_by slug: params[:dataset]
    unless @dataset
      render json: { error: 'Parameter `dataset` missing or not found. This must correspond to a dataset on which you are an editor.' }, status: :unprocessable_entity
      return
    end
  end

  def set_version
    @dataset_version = if params[:version].present?
                         @dataset.dataset_versions.find_by version: params[:version]
                       else
                         @dataset.dataset_version
                       end
    unless @dataset_version
      render json: { error: "Dataset version '#{params[:version]}' not found. A valid version must be provided." }, status: :unprocessable_entity
      return
    end
  end

  def set_or_create_version
    @dataset_version = @dataset.dataset_versions.where(version: params[:version]).first_or_create if params[:version].present?
    unless @dataset_version
      render json: { error: 'Parameter `version` missing or not found. A valid version must be provided.' }, status: :unprocessable_entity
      return
    end
  end
end
