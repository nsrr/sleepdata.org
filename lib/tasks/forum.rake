# frozen_string_literal: true

namespace :forum do
  desc "Export Forum to CSV"
  task export: :environment do
    csv_file = File.join("tmp", "forum-#{Time.zone.today.strftime("%F")}.csv")
    CSV.open(csv_file, "wb") do |csv|
      csv << %w(TopicID Type UserName Text Replies Views)
      Topic.current.each do |topic|
        csv << [
          topic.id,
          "Topic",
          topic.user.username,
          topic.title.downcase.tr("\n", " "),
          topic.replies.current.count,
          topic.view_count
        ]
        topic.replies.current.each do |reply|
          csv << [
            topic.id,
            "Reply",
            reply.user.username,
            reply.description.downcase.tr("\n", " ")
          ]
        end
      end
    end
    puts "Created #{csv_file}"
  end
end
