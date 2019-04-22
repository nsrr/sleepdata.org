# frozen_string_literal: true

desc "Launched by crontab -e, send a daily digest to reviewers."
task reviewer_digest: :environment do
  # At 1am every week day, in production mode, for users who have "daily digest" email notification selected
  return unless EMAILS_ENABLED && Time.zone.today.on_weekday?

  User.current.where(emails_enabled: true).find_each do |user|
    next if (user.digest_data_requests_submitted.size + user.digest_data_requests_resubmit.size + user.digest_data_requests_approved.size).zero?

    ReviewerMailer.daily_digest(user).deliver_now
  end
end
