# frozen_string_literal: true

require "test_helper"

# Tests to make sure registration email render properly.
class RegistrationMailerTest < ActionMailer::TestCase
  test "welcome email with password" do
    user = users(:valid)
    mail = RegistrationMailer.welcome(user)
    assert_equal [user.email], mail.to
    assert_equal "Welcome to the NSRR!", mail.subject
    assert_match(/Welcome to the NSRR community!/, mail.body.encoded)
  end
end
