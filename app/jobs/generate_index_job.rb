class GenerateIndexJob < ActiveJob::Base
  queue_as :default

  def perform(dataset, folder)
    dataset.create_folder_index(folder)
  end
end
