# frozen_string_literal: true

require 'test_helper'

# Tests that mail views are rendered corretly, sent to correct user, and have a
# correct subject line.
class UserMailerTest < ActionMailer::TestCase
  test 'post replied email' do
    post = comments(:six)
    user = users(:two)

    # Send the email, then test that it got queued
    email = UserMailer.post_replied(post, user).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [user.email], email.to
    assert_equal "New Forum Reply: #{post.topic.name}", email.subject
    assert_match(/Someone posted a reply to the following topic:/, email.encoded)
  end

  test 'reviewer digest email' do
    valid = users(:valid)

    email = UserMailer.reviewer_digest(valid).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "Reviewer Digest for #{Time.zone.today.strftime('%a %d %b %Y')}", email.subject
    assert_match(/Dear #{valid.first_name},/, email.encoded)
  end

  test 'daua submitted email' do
    agreement = agreements(:one)
    valid = users(:valid)

    # Send the email, then test that it got queued
    email = UserMailer.daua_submitted(valid, agreement).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [valid.email], email.to
    assert_equal "#{agreement.user.name} Submitted a Data Access and Use Agreement", email.subject
    assert_match(
      /#{agreement.user.name} \[#{agreement.user.email}\] submitted a Data Access and Use Agreement\./,
      email.encoded
    )
  end

  test 'daua approved email' do
    agreement = agreements(:one)
    admin = users(:admin)

    # Send the email, then test that it got queued
    email = UserMailer.daua_approved(agreement, admin).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [agreement.user.email], email.to
    assert_equal 'Your DAUA Submission has been Approved', email.subject
    assert_match(/Your Data Access and Use Agreement submission has been approved\./, email.encoded)
  end

  test 'daua signed email' do
    agreement = agreements(:one)

    # Send the email, then test that it got queued
    email = UserMailer.daua_signed(agreement).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [agreement.user.email], email.to
    assert_equal 'Your DAUA has been Signed by your Duly Authorized Representative', email.subject
    assert_match(
      /Your Data Access and Use Agreement has been signed by \
#{agreement.duly_authorized_representative_signature_print}, your Duly Authorized Representative\./,
      email.encoded
    )
  end

  test 'daua sent back for resubmission email' do
    agreement = agreements(:one)
    admin = users(:admin)

    # Send the email, then test that it got queued
    email = UserMailer.sent_back_for_resubmission(agreement, admin).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [agreement.user.email], email.to
    assert_equal 'Please Resubmit your DAUA', email.subject
    assert_match(/Your Data Access and Use Agreement submission was missing required information\./, email.encoded)
  end

  test 'daua progress notification email' do
    agreement = agreements(:one)
    agreement_event = agreement_events(:one_approved)
    admin = users(:admin)

    # Send the email, then test that it got queued
    email = UserMailer.daua_progress_notification(agreement, admin, agreement_event).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [admin.email], email.to
    assert_equal "#{agreement.name}'s DAUA Status Changed to #{agreement.status.titleize}", email.subject
    assert_match(/#{agreement.user.name}'s DAUA has been approved by FirstAdmin LastAdmin\./, email.encoded)
  end

  test 'mentioned during review of agreement email' do
    valid = users(:valid)
    agreement_event = agreement_events(:one_commented)

    # Send the email, then test that it got queued
    email = UserMailer.mentioned_in_agreement_comment(agreement_event, valid).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [valid.email], email.to
    assert_equal "#{agreement_event.user.name} Mentioned You While Reviewing an Agreement", email.subject
    assert_match(/#{agreement_event.user.name} mentioned you while reviewing an agreement\./, email.encoded)
  end

  test 'dataset hosting request submitted email' do
    hosting_request = hosting_requests(:one)

    # Send the email, then test that it got queued
    email = UserMailer.hosting_request_submitted(hosting_request).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [ENV['support_email']], email.to
    assert_equal "#{hosting_request.user.name} - Dataset Hosting Request", email.subject
    assert_match(
      /#{hosting_request.user.name} \[#{hosting_request.user.email}\] submitted a Dataset Hosting Request\./,
      email.encoded
    )
  end
end
