desc 'Launched by crontab -e, send a daily digest of recent activities.'
task :daily_digest => :environment do
  # At 1am every week day, in production mode, for "System Admins" who have "daily digest" email notification selected
  User.system_admins.each do |user|
    if user.digest_comments.size > 0
      UserMailer.forum_digest(user).deliver if Rails.env.production? and (1..5).include?(Date.today.wday) # and user.email_on?(:daily_digest)
    end
  end
end
