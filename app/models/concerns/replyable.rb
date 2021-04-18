# frozen_string_literal: true

# Allows models to have replies.
module Replyable
  extend ActiveSupport::Concern

  included do
    # Relationships
    has_many :replies, -> { order :id }
    has_many :countable_replies, -> { current.shadow_banned(nil) }, class_name: "Reply"
    has_many :reply_users
  end

  def last_page(current_user)
    if current_user&.admin?
      ((replies.where(reply_id: nil).count - 1) / Reply::REPLIES_PER_PAGE) + 1
    else
      ((replies.where(reply_id: nil).shadow_banned(current_user).count - 1) / Reply::REPLIES_PER_PAGE) + 1
    end
  end

  def get_or_create_subscription(current_user); end
end
