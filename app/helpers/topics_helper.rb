# frozen_string_literal: true

# Loads the per-topic reading state shown on the forum index in a few queries, instead of
# running 5-10 queries for every topic row (started reading, unread count, next unread
# reply, and last page).
module TopicsHelper
  def preload_topic_reading(topics)
    ids = topics.map(&:id)
    @topic_reading = {}
    return if ids.empty?

    topic_users = \
      if current_user
        TopicUser.where(user_id: current_user.id, topic_id: ids).index_by(&:topic_id)
      else
        {}
      end

    # Unread root replies after the user's read position, with the first one to link to.
    unread = {}
    if topic_users.any?
      join = ActiveRecord::Base.sanitize_sql_array(
        [
          "INNER JOIN topic_users ON topic_users.topic_id = replies.topic_id AND topic_users.user_id = ?",
          current_user.id
        ]
      )
      Reply.current
           .where(reply_id: nil, topic_id: topic_users.keys)
           .joins(join)
           .where("replies.id > topic_users.current_reply_read_id")
           .group("replies.topic_id")
           .pluck(Arel.sql("replies.topic_id, COUNT(*), MIN(replies.id)"))
           .each { |topic_id, count, first_id| unread[topic_id] = [count, first_id] }
    end
    next_replies = Reply.where(id: unread.values.map(&:last)).index_by(&:id)

    # Root reply counts for the last page link, matching Replyable#last_page.
    root_scope = Reply.where(reply_id: nil, topic_id: ids)
    root_scope = root_scope.shadow_banned(current_user) unless current_user&.admin?
    root_counts = root_scope.group("replies.topic_id").count

    ids.each do |id|
      count, first_id = unread[id]
      @topic_reading[id] = {
        started: topic_users.key?(id),
        unread: count.to_i,
        next_reply: first_id && next_replies[first_id],
        last_page: ((root_counts[id].to_i - 1) / Reply::REPLIES_PER_PAGE) + 1
      }
    end
  end

  def topic_started_reading?(topic)
    reading = @topic_reading&.dig(topic.id)
    reading ? reading[:started] : topic.started_reading?(current_user)
  end

  def topic_unread_replies(topic)
    reading = @topic_reading&.dig(topic.id)
    reading ? reading[:unread] : topic.unread_replies(current_user)
  end

  def topic_next_unread_reply(topic)
    reading = @topic_reading&.dig(topic.id)
    reading ? reading[:next_reply] : topic.next_unread_reply(current_user)
  end

  def topic_last_page(topic)
    reading = @topic_reading&.dig(topic.id)
    reading ? reading[:last_page] : topic.last_page(current_user)
  end
end
