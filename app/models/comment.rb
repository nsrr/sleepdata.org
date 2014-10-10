class Comment < ActiveRecord::Base

  COMMENTS_PER_PAGE = 20

  # Concerns
  include Deletable

  # Callbacks
  after_create :touch_topic, :email_mentioned_users

  # Model Validation
  validates_presence_of :topic_id, :description, :user_id

  # Named Scopes
  scope :with_unlocked_topic, -> { where("comments.topic_id in (select topics.id from topics where topics.locked = ?)", false).references(:topics) }
  scope :digest_visible, -> { current.where("comments.topic_id in (select topics.id from topics where topics.deleted = ?) and comments.user_id in (select users.id from users where users.banned = ?)", false, false).references(:topics, :users) }

  # Model Relationships
  belongs_to :topic
  belongs_to :user

  def editable_by?(current_user)
    not self.topic.locked? and not self.user.banned? and (self.user == current_user or current_user.system_admin?)
  end

  def deletable_by?(current_user)
    self.user == current_user or current_user.system_admin?
  end

  def banned_or_deleted?
    self.user.banned? or self.deleted?
  end

  def number
    self.topic.comments.order(:id).pluck(:id).index(self.id) + 1 rescue 0
  end

  private

  def touch_topic
    self.topic.update last_comment_at: Time.now
  end

  def email_mentioned_users
    users = User.current.where(email_me_when_mentioned: true).reject{|u| u.username.blank?}.uniq.sort
    users.each do |user|
      UserMailer.mentioned_in_comment(self, user).deliver_later if Rails.env.production? and self.description.match(/@#{user.username}\b/i)
    end
  end

end
