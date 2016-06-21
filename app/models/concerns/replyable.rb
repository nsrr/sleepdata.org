# frozen_string_literal: true

# Allows models to have replies
module Replyable
  extend ActiveSupport::Concern

  included do
    # Model Relationships
    has_many :replies, -> { order :id }
    has_many :reply_users
  end

  def last_page
    ((replies.where(reply_id: nil).count - 1) / Reply::REPLIES_PER_PAGE) + 1
  end
end