class Comment < ActiveRecord::Base

  COMMENTS_PER_PAGE = 20

  # Concerns
  include Deletable

  # Callbacks
  after_create :touch_topic

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

  # Reply Emails sends emails if the following conditions are met:
  # 1) The topic subscriber has email notifications enabled
  # AND
  # 2) The topic subscriber is not the post creator
  def send_reply_emails!
    unless Rails.env.test? or Rails.env.development?
      pid = Process.fork
      if pid.nil? then
        # In child
        self.topic.subscribers.where.not(id: self.user_id).each do |u|
          UserMailer.post_replied(self, u).deliver_later if Rails.env.production?
        end
        Kernel.exit!
      else
        # In parent
        Process.detach(pid)
      end
    end
  end

  private

  def touch_topic
    self.topic.update last_comment_at: Time.zone.now
  end

end
