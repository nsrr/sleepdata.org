# frozen_string_literal: true

json.array!(@dataset_files) do |dataset_file|
  json.dataset           @dataset.slug
  json.full_path         dataset_file.full_path
  json.folder            dataset_file.folder
  json.file_name         dataset_file.file_name
  json.is_file           dataset_file.is_file
  json.file_size         dataset_file.file_size
  json.file_checksum_md5 dataset_file.file_checksum_md5
  json.archived          dataset_file.archived
end
