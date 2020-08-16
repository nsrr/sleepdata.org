# frozen_string_literal: true

# Exports forum posts and replies.Run using the following command:
# rails forum:export RAILS_ENV=production
namespace :forum do
  desc "Export Forum to CSV"
  task export: :environment do
    csv_file = File.join("tmp", "forum-#{Time.zone.today.strftime("%F")}.csv")
    CSV.open(csv_file, "wb") do |csv|
      csv << %w(TopicId Type UserName CreatedAt Text Replies Views)
      Topic.current.order(id: :desc).each do |topic|
        csv << [
          topic.id,
          "Topic",
          topic.user.username,
          topic.created_at,
          topic.title.downcase.tr("\n", " "),
          topic.replies.current.count,
          topic.view_count
        ]
        topic.replies.current.each do |reply|
          csv << [
            topic.id,
            "Reply",
            reply.user.username,
            reply.created_at,
            reply.description.downcase.tr("\n", " ")
          ]
        end
      end
    end
    puts "Created #{csv_file}"
  end
end
