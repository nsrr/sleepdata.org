# frozen_string_literal: true

# Represent Spout variable structure for variable pages.
class Variable < ApplicationRecord
  # Concerns
  include PgSearch
  pg_search_scope :search_full_text, against: {
    name: "A",
    display_name: "B",
    folder: "B",
    description: "C",
    units: "D",
    calculation: "D"
  }, associated_against: {
    variable_labels: { name: "B" }
  }, using: {
    tsearch: { any_word: true, normalization: 4, prefix: true }
  }, order_within_rank: "commonly_used desc"

  after_save :set_search_terms

  # Scopes
  scope :with_folder, ->(arg) { where "folder ~* ?", "(^#{arg})" }
  scope :latest, -> { joins(:dataset).where("variables.dataset_version_id = datasets.dataset_version_id").merge(Dataset.released) }

  # Validations
  validates :name, :display_name, :variable_type, :dataset_id, :dataset_version_id, presence: true
  validates :name, format: { with: /\A[a-z]\w*\Z/i }
  validates :name, length: { maximum: 32 }
  validates :name, uniqueness: { scope: [:dataset_id, :dataset_version_id], case_sensitive: false }

  # Relationships
  belongs_to :dataset
  belongs_to :domain, optional: true
  belongs_to :dataset_version
  has_many :variable_forms
  has_many :forms, through: :variable_forms
  has_many :variable_labels, -> { order :name }

  # Temporary while "version" is being deprecated
  def api_version
    dataset_version ? dataset_version.version : nil
  end

  def to_param
    name
  end

  def self.find_by_param(input)
    find_by(name: input)
  end

  def related_variables
    dataset
      .variables
      .where(dataset_version_id: dataset_version_id)
      .where("(search_terms ~* ? or name in (?)) and id != ?", "(\\m#{name}\\M)", search_terms.split(" "), id)
      .order(:folder, :name)
  end

  def set_search_terms
    terms = [name.downcase] + folder.to_s.split("/")
    terms += variable_labels.pluck(:name)
    terms += forms.pluck(:name)
    [display_name, units, calculation, description].each do |json_string|
      terms += json_string.to_s.split(/[^\w\d%]/).reject(&:blank?)
    end
    terms = terms.select { |a| a.to_s.strip.size > 1 }.collect { |b| b.downcase.strip }.uniq.sort.join(" ")
    update_column :search_terms, terms
  end
end
