# Represent Spout variable structure for variable pages
class Variable < ActiveRecord::Base
  serialize :labels, Array

  # Named Scopes
  scope :with_folder, -> (arg) { where 'folder ~* ?', "(^#{arg})" }
  scope :search, -> (arg) { where('search_terms ~* ?', arg.to_s.split(/\s/).collect { |l| l.to_s.gsub(/[^\w\d%]/, '') }.collect { |l| "(#{l})" }.join('|')) }

  # Model Validation
  validates :name, :display_name, :variable_type, :dataset_id, presence: true
  validates :name, format: { with: /\A[a-z]\w*\Z/i }
  validates :name, length: { maximum: 32 }
  validates :name, uniqueness: { scope: :dataset_id }

  # Model Relationships
  belongs_to :dataset
  belongs_to :domain
  has_many :variable_forms
  has_many :forms, through: :variable_forms

  def n
    0
  end

  def mean
    0
  end

  def stddev
    0
  end

  def median
    0
  end

  def min
    0
  end

  def max
    0
  end

  def unknown
    0
  end

  def total
    0
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
    dataset.variables.where("(search_terms ~* ? or name in (?)) and id != ?", "(\\m#{name}\\M)", search_terms.split(' '), id).order(:folder, :name)
  end

  def known_issues
    line_found = false
    result = []
    known_issues_file = File.join(dataset.data_dictionary_folder, 'KNOWNISSUES.md')
    if File.exist?(known_issues_file) && File.file?(known_issues_file)
      IO.foreach(known_issues_file) do |line|
        if line_found && Variable.starts_with?(line, '  - ')
          result << line
        elsif Variable.partial_match?(line, "\\[#{name}\\]")
          line_found = true
          result << line
        else
          line_found = false
        end
      end
    end
    result
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
end
