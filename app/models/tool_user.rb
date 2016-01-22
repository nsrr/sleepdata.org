class ToolUser < ApplicationRecord

  # Model Relationships
  belongs_to :tool
  belongs_to :user

end
