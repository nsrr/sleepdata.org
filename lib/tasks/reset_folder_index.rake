desc "Pulls a new version of the dataset data dictionary"
task reset_folder_index: :environment do
  puts "Refresh Folder Index"

  dataset = Dataset.find_by_id(ENV["DATASET_ID"])
  folder = ENV["FOLDER"]

  puts "Loaded Dataset: #{dataset.name}"

  puts "Locking Folder #{File.join('', folder)}"
  dataset.lock_folder!(folder)

  puts "Generating Index for #{File.join('', folder)}"
  GenerateIndexJob.perform_later(dataset, folder)

  puts "Refresh Dataset Folder Complete"
end
