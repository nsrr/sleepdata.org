# frozen_string_literal: true

namespace :broadcasts do
  desc 'Export Flow Limitation challenge to CSV'
  task create_slugs: :environment do
    Broadcast.find_each do |broadcast|
      broadcast.update slug: broadcast.title.parameterize
    end
  end
end
