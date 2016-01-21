require 'test_helper'

# Tests to make sure registration email render properly
class RegistrationMailerTest < ActionMailer::TestCase
  test 'welcome email with password' do
    user = users(:valid)
    pw = 'FAKEPASSWORD'
    email = RegistrationMailer.send_welcome_email_with_password(user, pw).deliver_now
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [user.email], email.to
    assert_equal 'Welcome to the NSRR - Account Created', email.subject
    assert_match(/Welcome to the NSRR community!/, email.encoded)
    assert_match(/To get you started, we have set a temporary/, email.encoded)
    assert_match(/password for your account:/, email.encoded)
    assert_match(/FAKEPASSWORD/, email.encoded)
  end
end
