class Api::V1::DictionaryController < Api::V1::BaseController
  def upload_dataset_csv
    upload = 'success'
    dataset_csv_folder = File.join(@dataset.files_folder, 'datasets')
    FileUtils.mkpath dataset_csv_folder
    new_file_location = ''
    begin
      if params[:file]
        new_file_location = File.join(dataset_csv_folder, params[:file].original_filename)
        FileUtils.cp params[:file].tempfile, new_file_location
      end
    rescue
    end

    if !File.exist?(new_file_location) || (File.exist?(new_file_location) && File.size(new_file_location) == 0)
      upload = 'failed'
    end

    render json: { upload: upload }
  end
end
