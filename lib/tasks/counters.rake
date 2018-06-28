# frozen_string_literal: true

namespace :counters do
  desc "Reset counter_cache for models."
  task reset: :environment do
    Broadcast.find_each { |broadcast| Broadcast.reset_counters(broadcast.id, :countable_replies) }
    Topic.find_each { |topic| Topic.reset_counters(topic.id, :countable_replies) }
    User.find_each { |user| User.reset_counters(user.id, :replies) }
  end
end
