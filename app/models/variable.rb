# Represent Spout variable structure for variable pages
class Variable < ActiveRecord::Base
  # Named Scopes
  scope :with_folder, -> (arg) { where "folder ~* ?", "(^#{arg})" }
  scope :search, -> (arg) { where("search_terms ~* ?", arg.to_s.split(/\s/).collect{|l| l.to_s.gsub(/[^\w\d%]/, '')}.collect{|l| "(\\m#{l})"}.join("|")) }

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
end
