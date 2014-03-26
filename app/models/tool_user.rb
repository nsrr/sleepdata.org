class ToolUser < ActiveRecord::Base

  # Model Relationships
  belongs_to :tool
  belongs_to :user

end
