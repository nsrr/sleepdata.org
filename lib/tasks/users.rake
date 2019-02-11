# frozen_string_literal: true

namespace :users do
  desc "Create an export for users."
  task export: :environment do
    tmp_folder = Rails.root.join("carrierwave", "exports")
    FileUtils.mkdir_p tmp_folder
    csv_file = File.join(tmp_folder, "users-#{Time.zone.today.strftime("%F")}.csv")
    CSV.open(csv_file, "wb") do |csv|
      csv << ["NSRR ID", "Full Name", "Email", "Emails Enabled"]
      User.current.find_each do |user|
        csv << [
          user.id,
          user.full_name,
          user.email,
          user.emails_enabled?
        ]
      end
    end
  end
end
