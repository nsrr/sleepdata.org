# frozen_string_literal: true

require "test_helper"

# Tests that mail views are rendered correctly, sent to correct user, and have a
# correct subject line.
class UserMailerTest < ActionMailer::TestCase
  test "reviewer digest email" do
    valid = users(:valid)
    mail = UserMailer.reviewer_digest(valid)
    assert_equal [valid.email], mail.to
    assert_equal "Reviewer Digest for #{Time.zone.today.strftime("%a %d %b %Y")}", mail.subject
    assert_match(/Dear #{valid.username},/, mail.body.encoded)
  end

  test "daua submitted email" do
    agreement = data_requests(:submitted)
    valid = users(:valid)
    mail = UserMailer.daua_submitted(valid, agreement)
    assert_equal [valid.email], mail.to
    assert_equal "#{agreement.user.username} Submitted a Data Request", mail.subject
    assert_match(
      /#{agreement.user.username} \[#{agreement.user.email}\] submitted a data request\./,
      mail.body.encoded
    )
  end

  test "daua resubmitted email" do
    agreement = data_requests(:resubmitted)
    valid = users(:valid)
    mail = UserMailer.daua_submitted(valid, agreement)
    assert_equal [valid.email], mail.to
    assert_equal "#{agreement.user.username} Resubmitted a Data Request", mail.subject
    assert_match(
      /#{agreement.user.username} \[#{agreement.user.email}\] resubmitted a data request\./,
      mail.body.encoded
    )
  end

  test "daua approved email" do
    agreement = data_requests(:approved)
    admin = users(:admin)
    mail = UserMailer.daua_approved(agreement, admin)
    assert_equal [agreement.user.email], mail.to
    assert_equal "Your Data Request has been Approved", mail.subject
    assert_match(/Your data request has been approved\./, mail.body.encoded)
  end

  test "daua sent back for resubmission email" do
    agreement = data_requests(:resubmit)
    admin = users(:admin)
    mail = UserMailer.sent_back_for_resubmission(agreement, admin)
    assert_equal [agreement.user.email], mail.to
    assert_equal "Please Resubmit your Data Request", mail.subject
    assert_match(/Your data request is missing required information\./, mail.body.encoded)
  end

  test "daua progress notification email" do
    agreement = data_requests(:approved)
    agreement_event = agreement_events(:approved_two)
    admin = users(:admin)
    mail = UserMailer.daua_progress_notification(agreement, admin, agreement_event)
    assert_equal [admin.email], mail.to
    assert_equal "#{agreement.name}'s Data Request Changed to Approved", mail.subject
    assert_match(
      /#{agreement.user.username}'s data request has been approved by principalrevieweronreleased\./,
      mail.body.encoded
    )
  end

  test "mentioned during review of agreement email" do
    reviewer = users(:reviewer_two_on_released)
    agreement_event = agreement_events(:submitted_two_comment)
    mail = UserMailer.mentioned_in_agreement_comment(agreement_event, reviewer)
    assert_equal [reviewer.email], mail.to
    assert_equal "#{agreement_event.user.username} Mentioned You While Reviewing a Data Request", mail.subject
    assert_match(/#{agreement_event.user.username} mentioned you while reviewing a data request\./, mail.body.encoded)
  end

  test "dataset hosting request submitted email" do
    hosting_request = hosting_requests(:one)
    mail = UserMailer.hosting_request_submitted(hosting_request)
    assert_equal [ENV["support_email"]], mail.to
    assert_equal "#{hosting_request.user.username} - Dataset Hosting Request", mail.subject
    assert_match(
      /#{hosting_request.user.username} \[#{hosting_request.user.email}\] submitted a Dataset Hosting Request\./,
      mail.body.encoded
    )
  end
end
