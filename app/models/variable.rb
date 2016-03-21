# frozen_string_literal: true

# Represent Spout variable structure for variable pages
class Variable < ApplicationRecord
  serialize :labels, Array

  after_save :set_search_terms

  # Named Scopes
  scope :with_folder, -> (arg) { where 'folder ~* ?', "(^#{arg})" }
  scope :search, -> (arg) { where('search_terms ~* ?', arg.to_s.split(/\s/).collect { |l| l.to_s.gsub(/[^\w\d%]/, '') }.collect { |l| "(#{l})" }.join('|')) }
  scope :latest, -> { joins(:dataset).where('variables.dataset_version_id = datasets.dataset_version_id').merge(Dataset.current.where(public: true)) }

  # Model Validation
  validates :name, :display_name, :variable_type, :dataset_id, :dataset_version_id, presence: true
  validates :name, format: { with: /\A[a-z]\w*\Z/i }
  validates :name, length: { maximum: 32 }
  validates :name, uniqueness: { scope: [:dataset_id, :dataset_version_id], case_sensitive: false }

  # Model Relationships
  belongs_to :dataset
  belongs_to :domain
  belongs_to :dataset_version
  has_many :variable_forms
  has_many :forms, through: :variable_forms

  # Temporary while "version" is being deprecated
  def api_version
    dataset_version ? dataset_version.version : nil
  end

  def score(labels)
    return labels.count + 1 if labels.include?(name)
    result = (commonly_used? ? 0.5 : 0)
    labels.each do |label|
      result += 1 unless (search_terms =~ /\b#{label}/i).nil?
    end
    result
  end

  def to_param
    name
  end

  def self.find_by_param(input)
    find_by_name(input)
  end

  def related_variables
    dataset.variables.where(dataset_version_id: dataset_version_id).where("(search_terms ~* ? or name in (?)) and id != ?", "(\\m#{name}\\M)", search_terms.split(' '), id).order(:folder, :name)
  end

  def self.max_score(search)
    130 * search.to_s.split(/\s/).reject(&:blank?).uniq.count
  end

  def relevance(search)
    rank(search)[:score]
  end

  def rank(search)
    reasons = []
    score = 0

    search.to_s.split(/\s/).reject(&:blank?).uniq.sort.each do |term|
      if Variable.exact_match?(name, term)
        score += 130
        reasons << "<code>#{term}</code> Exact Match Name (+130)"
      elsif label_exact_match?(term)
        score += 120
        reasons << "<code>#{term}</code> Exact Match Label (+120)"
      elsif Variable.starts_with?(name, term)
        score += 110
        reasons << "<code>#{term}</code> Starts With Name (+110)"
      elsif label_starts_with?(term)
        score += 100
        reasons << "<code>#{term}</code> Starts With Label (+100)"
      elsif Variable.partial_match?(name, term)
        score += 90
        reasons << "<code>#{term}</code> Partial Match Name (+90)"
      elsif label_partial_match?(term)
        score += 80
        reasons << "<code>#{term}</code> Partial Match Label (+80)"
      elsif Variable.partial_match?(display_name, term)
        score += 70
        reasons << "<code>#{term}</code> Partial Match Display Name (+70)"
      elsif Variable.partial_match?(folder, term)
        score += 60
        reasons << "<code>#{term}</code> Partial Match Folder (+60)"
      elsif Variable.partial_match?(description, term)
        score += 50
        reasons << "<code>#{term}</code> Partial Match Description (+50)"
      elsif Variable.partial_match?(units, term)
        score += 40
        reasons << "<code>#{term}</code> Partial Match Units (+40)"
      elsif Variable.partial_match?(calculation, term)
        score += 40
        reasons << "<code>#{term}</code> Partial Match Calculation (+40)"
      end
    end

    if commonly_used && score != 0
      score += 25
      reasons << 'Commonly Used (+25)'
    end
    { score: score, reasons: reasons }
  end

  def label_exact_match?(term)
    labels.each do |label|
      return true if Variable.exact_match?(label, term)
    end
    false
  end

  def label_starts_with?(term)
    labels.each do |label|
      return true if Variable.starts_with?(label, term)
    end
    false
  end

  def label_partial_match?(term)
    labels.each do |label|
      return true if Variable.partial_match?(label, term)
    end
    false
  end

  def self.exact_match?(string, term)
    string.to_s.downcase == term.to_s.downcase
  end

  def self.starts_with?(string, term)
    !(/^#{term.to_s.downcase}/ =~ string.to_s.downcase).nil?
  end

  def self.partial_match?(string, term)
    !(/#{term.to_s.downcase}/ =~ string.to_s.downcase).nil?
  end

  def rank_sort_order(search)
    common = (commonly_used? ? 0 : 1)
    [-rank(search)[:score], common, folder, name]
  end

  def set_search_terms
    terms = [name.downcase] + folder.to_s.split('/')
    terms += labels
    terms += forms.pluck(:name)
    [display_name, units, calculation, description].each do |json_string|
      terms += json_string.to_s.split(/[^\w\d%]/).reject(&:blank?)
    end
    terms = terms.select { |a| a.to_s.strip.size > 1 }.collect { |b| b.downcase.strip }.uniq.sort.join(' ')
    update_column :search_terms, terms
  end
end
