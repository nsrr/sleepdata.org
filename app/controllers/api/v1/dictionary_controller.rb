# Creates an API for editors to update existing dataset dictionaries
class Api::V1::DictionaryController < Api::V1::BaseController
  def upload_dataset_csv
    upload = 'success'
    dataset_csv_folder = File.join(@dataset.files_folder, 'datasets', get_folder)
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

  private

  def get_folder
    path = params[:folder].to_s.downcase.gsub(%r{[^a-zA-Z0-9/\.-]}, '-')
    folders = path.split('/').reject(&:blank?).reject { |f| /^\./ =~ f }
    folder = folders.join('/')
  end
end
