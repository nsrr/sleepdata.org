class Variable < ActiveRecord::Base

  # Model Validation
  validates_presence_of :name, :display_name, :variable_type, :dataset_id
  validates_format_of :name, with: /\A[a-z]\w*\Z/i
  validates :name, length: { maximum: 32 }
  validates_uniqueness_of :name, scope: :dataset_id

  # Model Relationships
  belongs_to :dataset
  belongs_to :domain
  has_many :variable_forms
  has_many :forms, through: :variable_forms

  def score(labels)
    return labels.count + 1 if labels.include?(self.name)
    result = (self.commonly_used? ? 0.5 : 0)
    labels.each do |label|
      result += 1 if (self.search_terms =~ /\b#{label}/i) != nil
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
    self.dataset.variables.where("(search_terms ~* ? or name in (?)) and id != ?", "(\\m#{self.name}\\M)", self.search_terms.split(' '), self.id).order(:folder, :name)
  end

end
