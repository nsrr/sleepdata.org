class DatasetFileAudit < ActiveRecord::Base

  # Model Relationships
  belongs_to :dataset
  belongs_to :user

  scope :audit_before, lambda { |arg| where("dataset_file_audits.created_at < ?", (arg+1.day).at_midnight) }
  scope :audit_after, lambda { |arg| where("dataset_file_audits.created_at >= ?", arg.at_midnight) }

end
