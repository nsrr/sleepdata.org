# frozen_string_literal: true

require "test_helper"

# Make sure daily digest can be rendered for viewers.
class ReviewerMailerTest < ActionMailer::TestCase
  test "daily digest email" do
    regular = users(:reviewer_on_released)
    mail = ReviewerMailer.daily_digest(regular)
    assert_equal [regular.email], mail.to
    assert_equal "Daily Digest for #{Time.zone.today.strftime("%a %d %b %Y")}", mail.subject
    assert_match(
      /Here's your personalized recap for #{Time.zone.today.strftime("%A, %B %-d, %Y")}\./,
      mail.body.encoded
    )
  end
end
