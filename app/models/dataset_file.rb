# frozen_string_literal: true

# Tracks file and folder information.
class DatasetFile < ApplicationRecord
  # Concerns
  include Deletable

  # Scopes
  scope :order_by_type, -> { order(:is_file, :file_name) }

  # Validations
  validates :dataset_id, :file_size, :file_time, presence: true
  validates :full_path, uniqueness: { scope: :dataset_id, case_sensitive: false }
  validates :file_size, numericality: { greater_than_or_equal_to: 0 }

  # Relationships
  belongs_to :dataset

  # Methods

  # TODO: Change to accommodate commercial/noncommercial based on user and file setting.
  def downloadable_by_user?(current_user)
    publicly_available? || dataset.approved_data_request?(current_user)
  end

  def file_exist?
    File.exist?(filesystem_path)
  end

  def filesystem_path
    File.join(dataset.files_folder, full_path)
  end

  def pdf?
    file_name.split(".").last.to_s.casecmp("pdf").zero?
  end

  def md?
    file_name.split(".").last.to_s.casecmp("md").zero?
  end

  def image?
    extension = file_name.split(".").last.to_s.downcase
    %(png jpg jpeg gif).include?(extension)
  end

  def verify_file!
    destroy unless file_exist?
  end

  def destroy
    super
    update_column :file_checksum_md5, nil
  end

  def generate_checksum_md5!
    checksum = \
      if is_file
        if file_checksum_md5.nil?
          Digest::MD5.file(filesystem_path).hexdigest
        else
          file_checksum_md5
        end
      end
    update file_checksum_md5: checksum
  end
end
