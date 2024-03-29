# frozen_string_literal: true

namespace :users do
  desc "Create an export for users."
  task export: :environment do
    tmp_folder = Rails.root.join("carrierwave", "exports")
    FileUtils.mkdir_p tmp_folder
    csv_file = File.join(tmp_folder, "users-#{Time.zone.today.strftime("%F")}.csv")
    CSV.open(csv_file, "wb") do |csv|
      csv << ["NSRR ID", "Full Name", "ORCID iD", "Email", "Email Confirmed", "Emails Enabled", "Username", "Login Count", "Join Date", "Last Login Date"]
      users = User.current.order(:id)
      user_count = users.count
      users.each_with_index do |user, index|
        print "\r#{index + 1} of #{user_count} (#{(index + 1) * 100 / user_count}%)"
        csv << [
          user.id,
          user.full_name,
          user.orcidid,
          user.email,
          user.confirmed?,
          user.emails_enabled?,
          user.username,
          user.sign_in_count,
          user.created_at&.strftime("%F"),
          user.current_sign_in_at&.strftime("%F")
        ]
      end
      puts "\n...DONE"
      puts csv_file.white
    end
  end

  desc "Purge unconfirmed accounts that are older than one year old."
  task purge_unconfirmed_accounts: :environment do
    User.current.where("created_at < ?", Time.zone.now - 1.year).where(confirmed_at: nil).destroy_all
  end
end
