# frozen_string_literal: true

namespace :topics do
  desc "Create new slugs for existing topics."
  task create_slugs: :environment do
    puts "Topics with slugs: #{Topic.where.not(slug: nil).count}"
    Topic.find_each do |topic|
      unless topic.update slug: topic.title.parameterize
        puts "Topic #{topic.id} was not updated successfully."
      end
    end
    puts "Topics with slugs: #{Topic.where.not(slug: nil).count}"
  end
end
