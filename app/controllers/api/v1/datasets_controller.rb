# frozen_string_literal: true

# JSON API to allow users to download files from datasets.
class Api::V1::DatasetsController < Api::V1::ViewerController
  before_action :find_viewable_dataset_or_redirect, only: [:show, :files]
  before_action :find_dataset_file, only: [:files]

  def index
    @datasets = viewable_datasets.order(:name).page(params[:page]).per(18)
  end

  def show
  end

  def files
    path = @dataset.find_file_folder(params[:path])
    folder = path.blank? ? '' : "#{path}/"
    @dataset_files = if @dataset_file && @dataset_file.is_file?
                       @dataset.non_root_dataset_files.where(id: @dataset_file.id).order_by_type
                     elsif path == params[:path].to_s
                       @dataset.non_root_dataset_files.where(folder: folder).order_by_type
                     else
                       DatasetFile.none
                     end
  end

  private

  def find_viewable_dataset_or_redirect
    super(:id)
  end

  def find_dataset_file
    @dataset_file = @dataset.dataset_files.current.find_by(full_path: params[:path])
  end

  def viewable_datasets
    if current_user
      current_user.all_viewable_datasets
    else
      Dataset.current.where(public: true)
    end
  end
end
