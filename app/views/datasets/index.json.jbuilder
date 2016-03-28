# frozen_string_literal: true

json.array!(@datasets) do |dataset|
  json.partial! 'datasets/dataset', dataset: dataset
  json.path dataset_path(dataset, format: :json)
end
