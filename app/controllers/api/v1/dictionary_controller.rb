# frozen_string_literal: true

# Creates an API for editors to update existing dataset dictionaries
class Api::V1::DictionaryController < Api::V1::BaseController
  def upload_file
    upload = 'success'
    file_folder = File.join(@dataset.files_folder, get_folder)
    FileUtils.mkpath file_folder
    new_file_location = ''
    begin
      if params[:file]
        new_file_location = File.join(file_folder, params[:file].original_filename)
        FileUtils.cp params[:file].tempfile, new_file_location
      end
    rescue
    end

    if !File.exist?(new_file_location) || (File.exist?(new_file_location) && File.size(new_file_location) == 0)
      upload = 'failed'
    end

    render json: { upload: upload }
  end

  def refresh
    @dataset.recompute_datasets_folder_indices_in_background(get_folders)
    render json: { refresh: 'success' }
  end

  def update_default_version
    dataset_version = @dataset.dataset_versions.find_by(version: params[:version])
    if dataset_version
      @dataset.update dataset_version_id: dataset_version.id
      render json: { version_update: 'success' }
    else
      render json: { version_update: 'fail' }
    end
  end

  private

  def get_folder
    clean_folder(params[:folder])
  end

  def get_folders
    (params[:folders] || []).collect { |folder| clean_folder(folder) }
  end

  def clean_folder(folder)
    path = folder.to_s.downcase.gsub(%r{[^a-zA-Z0-9/\.-]}, '-')
    folders = path.split('/').reject(&:blank?).reject { |f| /^\./ =~ f }
    folders.join('/')
  end
end
