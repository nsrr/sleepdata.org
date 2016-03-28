# frozen_string_literal: true

# Allows dataset admins to create and deleted datasets.
class Admin::DatasetsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_system_admin
  before_action :find_editable_dataset_or_redirect, only: [:destroy]

  # GET /datasets/new
  def new
    @dataset = Dataset.new
  end

  # POST /datasets
  def create
    @dataset = current_user.datasets.new(dataset_params)
    if @dataset.save
      redirect_to @dataset, notice: 'Dataset was successfully created.'
    else
      render :new
    end
  end

  # DELETE /datasets/1
  def destroy
    @dataset.destroy
    redirect_to datasets_path
  end

  private

  def find_editable_dataset_or_redirect
    super(:id)
  end

  # TODO: (Reduce duplication) Copied from editor/datasets_controller.rb
  def dataset_params
    params[:dataset] ||= { blank: '1' }
    params[:dataset][:release_date] = parse_date(params[:dataset][:release_date])
    params.require(:dataset).permit(
      :name, :description, :slug, :logo, :logo_cache, :public,
      :all_files_public, :git_repository, :release_date, :info_what, :info_who,
      :info_when, :info_funded_by, :info_citation, :info_size
      )
  end
end
