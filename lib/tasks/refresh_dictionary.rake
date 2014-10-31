desc "Pulls a new version of the dataset data dictionary"
task refresh_dictionary: :environment do
  dataset = Dataset.find_by_id(ENV["DATASET_ID"])

  LoadDataDictionaryJob.perform_later(dataset)
  GenerateIndexJob.perform_later(dataset, nil) # Root
  GenerateIndexJob.perform_later(dataset, 'datasets')
end
