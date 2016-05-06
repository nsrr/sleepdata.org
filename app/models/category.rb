# frozen_string_literal: true

# Allows broadcasts to be grouped by category.
# class Category < ApplicationRecord # Rails5
class Category < ActiveRecord::Base
  # Concerns
  include Deletable

  # Model Validation
  validates :name, :slug, presence: true
  validates :slug, uniqueness: { scope: :deleted }
  validates :slug, format: { with: /\A(?!\Anew\Z)[a-z][a-z0-9\-]*\Z/ }

  # Model Relationships
  has_many :broadcasts, -> { current }

  # Model Methods

  def to_param
    slug.blank? ? id.to_s : slug
  end

  def self.find_by_param(input)
    where('categories.slug = ? or categories.id = ?', input.to_s, input.to_i).first
  end
end
