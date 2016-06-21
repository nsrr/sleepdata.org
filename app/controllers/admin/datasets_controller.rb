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
    redirect_to datasets_path, notice: 'Dataset was successfully deleted.'
  end

  private

  def find_editable_dataset_or_redirect
    super(:id)
  end
end
