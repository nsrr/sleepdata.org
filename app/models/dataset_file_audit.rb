class DatasetFileAudit < ActiveRecord::Base

  # Model Relationships
  belongs_to :dataset
  belongs_to :user

  # Named Scopes
  scope :audit_before, lambda { |arg| where("dataset_file_audits.created_at < ?", (arg+1.day).at_midnight) }
  scope :audit_after, lambda { |arg| where("dataset_file_audits.created_at >= ?", arg.at_midnight) }
  scope :regular_members, -> { joins(:user).merge(User.current.where(aug_member: false, core_member: false)) }
  scope :aug_or_core_members, -> { joins(:user).merge(User.current.where("aug_member = ? or core_member = ?", true, true)) }

end
