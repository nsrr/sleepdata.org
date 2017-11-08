# frozen_string_literal: true

# Allows files to be attached to documents.
class SupportingDocumentUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    data_request_id = model.data_request_id.to_s
    File.join(
      "data_requests",
      data_request_id,
      model.class.to_s.underscore.pluralize,
      model.id.to_s
    )
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Process files as they are uploaded:
  process resize_to_limit: [1140, 1140], if: :image?

  # Create different versions of your uploaded files:
  version :preview, if: :image? do
    process resize_to_fill: [512, 512]
  end

  version :thumb, if: :image? do
    process resize_to_fill: [128, 128]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_whitelist
    %w(pdf jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  process :save_file_size_in_model

  def save_file_size_in_model
    model.file_size = file.size
  end

  protected

  def image?(new_file)
    %w(jpg jpeg gif png).include?(new_file.extension&.downcase)
  end
end
