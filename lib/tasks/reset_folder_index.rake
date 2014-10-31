desc "Pulls a new version of the dataset data dictionary"
task reset_folder_index: :environment do
  dataset = Dataset.find_by_id(ENV["DATASET_ID"])
  folder = ENV["FOLDER"]

  dataset.lock_folder!(folder)
  GenerateIndexJob.perform_later(dataset, folder)
end
