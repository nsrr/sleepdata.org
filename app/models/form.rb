# frozen_string_literal: true

# Represents the PDF or CRF on which a variable was captured
class Form < ActiveRecord::Base
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
    dataset.grants_file_access_to?(current_user) || dataset.public_file?(full_location)
  end

  def full_location
    ['forms', folder, code_book].reject(&:blank?).join('/')
  end

  def file_missing?
    !File.exist?(dataset.find_file(full_location))
  end
end
