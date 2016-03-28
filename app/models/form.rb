# frozen_string_literal: true

# Represents the PDF or CRF on which a variable was captured
class Form < ApplicationRecord
  # Model Validation
  validates :name, :dataset_id, :dataset_version_id, presence: true
  validates :name, format: { with: /\A[a-z]\w*\Z/i }
  validates :name, uniqueness: { scope: [:dataset_id, :dataset_version_id], case_sensitive: false }

  # Model Relationships
  belongs_to :dataset
  belongs_to :dataset_version
  has_many :variable_forms
  has_many :variables

  def pdf?
    extension == 'pdf'
  end

  def image?
    %w(png jpg jpeg gif).include?(extension)
  end

  def extension
    code_book.split('.').last.to_s.downcase
  end

  def viewable_by_user?(current_user)
    dataset_file ? dataset_file.downloadable_by_user?(current_user) : false
  end

  def full_location
    ['forms', folder, code_book].reject(&:blank?).join('/')
  end

  def file_missing?
    dataset_file ? !dataset_file.file_exist? : true
  end

  def dataset_file
    dataset.dataset_files.current.find_by(full_path: full_location, is_file: true)
  end
end
