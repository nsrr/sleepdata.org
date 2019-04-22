# frozen_string_literal: true

# Generates previews for reviewer daily digest emails.
class ReviewerMailerPreview < ActionMailer::Preview
  def daily_digest
    user = User.first
    ReviewerMailer.daily_digest(user)
  end
end
