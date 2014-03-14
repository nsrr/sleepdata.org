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
    assert_match(/#{valid.name} \[#{valid.email}\] has signed up for an account\./, email.encoded)
  end

  test "dua submitted email" do
    agreement = agreements(:one)
    admin = users(:admin)

    # Send the email, then test that it got queued
    email = UserMailer.dua_submitted(admin, agreement).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [admin.email], email.to
    assert_equal "#{agreement.user.name} Submitted a Data Access and Use Agreement", email.subject
    assert_match(/#{agreement.user.name} \[#{agreement.user.email}\] has submitted a Data Access and Use Agreement\./, email.encoded)
  end

  test "dua approved email" do
    agreement = agreements(:one)
    admin = users(:admin)

    # Send the email, then test that it got queued
    email = UserMailer.dua_approved(agreement, admin).deliver
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal [agreement.user.email], email.to
    assert_equal "Your DAUA Submission has been Approved", email.subject
    assert_match(/Your Data Access and Use Agreement submission has been approved\./, email.encoded)
  end

  test "dua sent back for resubmission email" do
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


end
