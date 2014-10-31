class LoadDataDictionaryJob < ActiveJob::Base
  queue_as :default

  def perform(dataset)
    dataset.load_data_dictionary!
  end
end
