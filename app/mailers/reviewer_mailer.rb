# frozen_string_literal: true

# Emails a daily digest of number of data requests approved, and those sent back
# for resubmission.
class ReviewerMailer < ApplicationMailer
  def daily_digest(user)
    setup_email
    @user = user
    @email_to = user.email
    @data_requests_submitted = user.digest_data_requests_submitted
    @data_requests_resubmit = user.digest_data_requests_resubmit
    @data_requests_approved = user.digest_data_requests_approved
    mail(to: @email_to, subject: "Daily Digest for #{Time.zone.today.strftime("%a %d %b %Y")}")
  end
end
