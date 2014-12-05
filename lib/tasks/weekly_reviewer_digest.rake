desc 'Launched by crontab -e, send a daily digest of recent activities.'
task :weekly_reviewer_digest => :environment do
  # At 1am once a week, in production mode, for members who have "daily digest" email notification selected
  User.current.each do |user|
    if user.digest_reviews.size > 0
      UserMailer.reviewer_digest(user).deliver_later if Rails.env.production? # and user.email_on?(:daily_digest)
    end
  end
end
