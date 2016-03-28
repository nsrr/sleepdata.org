# frozen_string_literal: true
# TODO: Change to class DatasetFile < ApplicationRecord in Rails5

# Tracks file and folder information
class DatasetFile < ActiveRecord::Base
  # Concerns
  include Deletable

  # Scopes
  scope :order_by_type, -> { order(:is_file, :file_name) }

  # Model Validation
  validates :dataset_id, :full_path, :file_name, :file_size, :file_time, presence: true
  validates :full_path, uniqueness: { scope: [:dataset_id, :is_file], case_sensitive: false }
  validates :file_size, numericality: { greater_than_or_equal_to: 0 }

  # Model Relationships
  belongs_to :dataset

  # Model Methods

  def downloadable_by_user?(current_user)
    publicly_available? || dataset.grants_file_access_to?(current_user)
  end

  def file_exist?
    File.exist?(filesystem_path)
  end

  def filesystem_path
    File.join(dataset.files_folder, full_path)
  end

  def pdf?
    file_name.split('.').last.to_s.casecmp('pdf') == 0
  end
end
