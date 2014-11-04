desc "Pulls a new version of the dataset data dictionary"
task refresh_dictionary: :environment do
  puts "Refresh Dataset Started"

  dataset = Dataset.find_by_id(ENV["DATASET_ID"])
  puts "Loaded Dataset: #{dataset.name}"

  puts "Loading Data Dictionary"
  LoadDataDictionaryJob.perform_later(dataset)

  puts "Generating Index for /"
  dataset.lock_folder!(nil)
  GenerateIndexJob.perform_later(dataset, nil)

  puts "Generating Index for /datasets"
  dataset.lock_folder!('datasets')
  GenerateIndexJob.perform_later(dataset, 'datasets')

  puts "Refresh Dataset Complete"
end
