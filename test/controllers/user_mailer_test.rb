require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  test "notify system admin email" do
    valid = users(:valid)
    admin = users(:admin)

    # Send the email, then test that it got queued
    email = UserMailer.notify_system_admin(admin, valid).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [admin.email], email.to
    assert_equal "#{valid.name} Signed Up", email.subject
    assert_match(/#{valid.name} \[#{valid.email}\] signed up for an account\./, email.encoded)
  end

  test "daua submitted email" do
    agreement = agreements(:one)
    admin = users(:admin)

    # Send the email, then test that it got queued
    email = UserMailer.daua_submitted(admin, agreement).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [admin.email], email.to
    assert_equal "#{agreement.user.name} Submitted a Data Access and Use Agreement", email.subject
    assert_match(/#{agreement.user.name} \[#{agreement.user.email}\] submitted a Data Access and Use Agreement\./, email.encoded)
  end

  test "daua approved email" do
    agreement = agreements(:one)
    admin = users(:admin)

    # Send the email, then test that it got queued
    email = UserMailer.daua_approved(agreement, admin).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [agreement.user.email], email.to
    assert_equal "Your DAUA Submission has been Approved", email.subject
    assert_match(/Your Data Access and Use Agreement submission has been approved\./, email.encoded)
  end

  test "daua sent back for resubmission email" do
    agreement = agreements(:one)
    admin = users(:admin)

    # Send the email, then test that it got queued
    email = UserMailer.sent_back_for_resubmission(agreement, admin).deliver
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
    email = UserMailer.daua_progress_notification(agreement, admin).deliver
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
    email = UserMailer.dataset_access_requested(dataset_user, editor).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [editor.email], email.to
    assert_equal "#{dataset_user.user.name} Requested Dataset File Access on #{dataset_user.dataset.name}", email.subject
    assert_match(/#{dataset_user.user.name} \[#{dataset_user.user.email}\] requested file access on #{dataset_user.dataset.name}\./, email.encoded)
  end

end
