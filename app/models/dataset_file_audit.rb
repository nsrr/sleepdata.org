class DatasetFileAudit < ActiveRecord::Base

  # Model Relationships
  belongs_to :dataset
  belongs_to :user

  # Named Scopes
  scope :audit_before, lambda { |arg| where("dataset_file_audits.created_at < ?", (arg+1.day).at_midnight) }
  scope :audit_after, lambda { |arg| where("dataset_file_audits.created_at >= ?", arg.at_midnight) }
  scope :regular_members, -> { where("dataset_file_audits.user_id in (select users.id from users where users.deleted = ? and users.aug_member = ? and users.core_member = ?)", false, false, false).references(:users) }
  scope :aug_or_core_members, -> { where("dataset_file_audits.user_id in (select users.id from users where users.deleted = ? and (users.aug_member = ? or users.core_member = ?))", false, true, true).references(:users) }

end
