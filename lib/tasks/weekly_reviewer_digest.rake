# frozen_string_literal: true

desc 'Launched by crontab -e, send a daily digest of recent activities.'
task weekly_reviewer_digest: :environment do
  return unless EMAILS_ENABLED
  # At 1am once a week, in production mode, for members who have "daily digest" email notification selected
  User.current.each do |user|
    UserMailer.reviewer_digest(user).deliver_now if user.digest_reviews.size > 0
  end
end
