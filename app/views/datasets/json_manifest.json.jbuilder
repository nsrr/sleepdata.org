# frozen_string_literal: true

json.array!(@dataset_files) do |dataset_file|
  json.file_name dataset_file.file_name
  json.checksum  dataset_file.file_checksum_md5
  json.is_file   dataset_file.is_file
  json.file_size dataset_file.file_size
  json.dataset   @dataset.slug
  json.file_path dataset_file.full_path
end
