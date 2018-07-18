# frozen_string_literal: true

require "test_helper"

# Tests to make sure organization invitation emails render properly.
class OrganizationMailerTest < ActionMailer::TestCase
  test "invitation" do
    organization_user = organization_users(:editor_invite)
    mail = OrganizationMailer.invitation(organization_user)
    assert_equal ["editor_invite@example.com"], mail.to
    assert_equal "editor invited you to the Organization One Organization on the NSRR", mail.subject
    assert_match(/editor invited you to join the Organization One organization on the NSRR\./, mail.body.encoded)
    assert_match(/#{ENV["website_url"]}\/invite\/EDITOR_INVITE_TOKEN/, mail.body.encoded)
  end
end
