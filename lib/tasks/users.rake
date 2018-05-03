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

  # TODO: Remove in v34.0.0
  desc "Merge first name and last name into full name"
  task migrate_full_name: :environment do
    User.current.find_each do |user|
      update_full_name_and_username(user)
    end
    User.find_each do |user|
      update_full_name_and_username(user)
    end
  end
end

def update_full_name_and_username(user)
  return if user.username.present? && user.full_name.present?
  if user.username.present?
    user.update(full_name: "#{user.first_name} #{user.last_name}")
  else
    begin
      count ||= 0
      first_part = "#{user.first_name}#{user.last_name}".gsub(/[^a-zA-Z0-9]/, "").strip.downcase.presence || "member#{100 + rand(900)}"
      user.update!(
        full_name: "#{user.first_name} #{user.last_name}",
        username: "#{first_part}#{count if count.positive?}"
      )
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      count += 1
      retry
    end
  end
  puts "#{user.id} #{user.full_name.ljust(34)} #{user.username}"
end
