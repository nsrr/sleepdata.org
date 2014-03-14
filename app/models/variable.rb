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
  has_many :forms

  def score(labels)
    return labels.count + 1 if labels.include?(self.name)
    result = (self.commonly_used? ? 0.5 : 0)
    labels.each do |label|
      result += 1 if (self.search_terms =~ /\b#{label}/i) != nil
    end
    result
  end

end
