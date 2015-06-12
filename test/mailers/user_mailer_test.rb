require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  test "post replied email" do
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

  test "reviewer digest email" do
    valid = users(:valid)

    email = UserMailer.reviewer_digest(valid).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    assert_equal [valid.email], email.to
    assert_equal "Reviewer Digest for #{Date.today.strftime('%a %d %b %Y')}", email.subject
    assert_match(/Dear #{valid.first_name},/, email.encoded)
  end

  test "daua submitted email" do
    agreement = agreements(:one)
    valid = users(:valid)

    # Send the email, then test that it got queued
    email = UserMailer.daua_submitted(valid, agreement).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [valid.email], email.to
    assert_equal "#{agreement.user.name} Submitted a Data Access and Use Agreement", email.subject
    assert_match(/#{agreement.user.name} \[#{agreement.user.email}\] submitted a Data Access and Use Agreement\./, email.encoded)
  end

  test "daua approved email" do
    agreement = agreements(:one)
    admin = users(:admin)

    # Send the email, then test that it got queued
    email = UserMailer.daua_approved(agreement, admin).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [agreement.user.email], email.to
    assert_equal "Your DAUA Submission has been Approved", email.subject
    assert_match(/Your Data Access and Use Agreement submission has been approved\./, email.encoded)
  end

  test "daua signed email" do
    agreement = agreements(:one)

    # Send the email, then test that it got queued
    email = UserMailer.daua_signed(agreement).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [agreement.user.email], email.to
    assert_equal "Your DAUA has been Signed by your Duly Authorized Representative", email.subject
    assert_match(/Your Data Access and Use Agreement has been signed by #{agreement.duly_authorized_representative_signature_print}, your Duly Authorized Representative\./, email.encoded)
  end

  test "daua sent back for resubmission email" do
    agreement = agreements(:one)
    admin = users(:admin)

    # Send the email, then test that it got queued
    email = UserMailer.sent_back_for_resubmission(agreement, admin).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [agreement.user.email], email.to
    assert_equal "Please Resubmit your DAUA", email.subject
    assert_match(/Your Data Access and Use Agreement submission was missing required information\./, email.encoded)
  end

  test "daua progress notification email" do
    agreement = agreements(:one)
    admin = users(:admin)

    # Send the email, then test that it got queued
    email = UserMailer.daua_progress_notification(agreement, admin).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [admin.email], email.to
    assert_equal "#{agreement.name}'s DAUA Status Changed to #{agreement.status.titleize}", email.subject
    assert_match(/#{agreement.user.name}'s DAUA has been approved by FirstAdmin LastAdmin\./, email.encoded)
  end

  test "dataset file access requested email" do
    dataset_user = dataset_users(:editor_public_access)
    editor = users(:editor)

    # Send the email, then test that it got queued
    email = UserMailer.dataset_access_requested(dataset_user, editor).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [editor.email], email.to
    assert_equal "#{dataset_user.user.name} Requested Dataset File Access on #{dataset_user.dataset.name}", email.subject
    assert_match(/#{dataset_user.user.name} \[#{dataset_user.user.email}\] requested file access on #{dataset_user.dataset.name}\./, email.encoded)
  end

  test "dataset file access approved email" do
    dataset_user = dataset_users(:editor_public_access)
    editor = users(:editor)

    # Send the email, then test that it got queued
    email = UserMailer.dataset_access_approved(dataset_user, editor).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [dataset_user.user.email], email.to
    assert_equal "Your #{dataset_user.dataset.name} File Access Request Has Been Approved By #{editor.name}", email.subject
    assert_match(/#{editor.name} approved your file access request on #{dataset_user.dataset.name}\./, email.encoded)
  end

  test "mentioned during review of agreement email" do
    valid = users(:valid)
    agreement_event = agreement_events(:one)

    # Send the email, then test that it got queued
    email = UserMailer.mentioned_in_agreement_comment(agreement_event, valid).deliver_now
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [valid.email], email.to
    assert_equal "#{agreement_event.user.name} Mentioned You While Reviewing an Agreement", email.subject
    assert_match(/#{agreement_event.user.name} mentioned you while reviewing an agreement\./, email.encoded)
  end

end
