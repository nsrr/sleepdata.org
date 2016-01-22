class ToolContributor < ApplicationRecord

  # Model Relationships
  belongs_to :dataset
  belongs_to :user

end
