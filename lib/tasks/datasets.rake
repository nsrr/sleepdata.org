# frozen_string_literal: true

namespace :datasets do
  desc "Reset counter_cache for models."
  task popularity: :environment do
    format_length = User.count.to_s.size
    Dataset.find_each(&:recalculate_popularity!)
    Dataset.order(popularity: :desc).pluck(:slug, :popularity).collect do |slug, popularity|
      puts "#{"% #{format_length + 1}d" % popularity}".white + " #{slug}"
    end
  end
end
