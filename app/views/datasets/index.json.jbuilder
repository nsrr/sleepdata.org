json.array!(@datasets) do |dataset|
  json.partial! 'datasets/dataset', dataset: dataset
  json.path dataset_path(dataset, format: :json)
  # json.url dataset_url(dataset, format: :json)
end
