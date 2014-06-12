class Comment < ActiveRecord::Base

  # Concerns
  include Deletable

  # Model Validation
  validates_presence_of :topic_id, :description, :user_id

  # Named Scopes
  scope :with_unlocked_topic, -> { where("comments.topic_id in (select topics.id from topics where topics.locked = ?)", false).references(:topics) }

  # Model Relationships
  belongs_to :topic
  belongs_to :user

  def editable_by?(current_user)
    not self.topic.locked? and (self.user == current_user or current_user.system_admin?)
  end

  def deletable_by?(current_user)
    self.user == current_user or current_user.system_admin?
  end

end
