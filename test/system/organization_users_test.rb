# frozen_string_literal: true

require "application_system_test_case"

# System tests for adding and removing organization members.
class OrganizationUsersTest < ApplicationSystemTestCase
  setup do
    @editor = users(:editor)
    @organization = organizations(:one)
    @organization_user = organization_users(:one)
  end

  test "visiting the index" do
    visit organization_url(@organization)
    screenshot("organization-visit-team-index")
    click_on "Members"
    screenshot("organization-visit-team-index")
    click_on "Sign in"
    fill_in "user[email]", with: @editor.email
    fill_in "user[password]", with: "password"
    screenshot("organization-visit-team-index")
    click_form_submit
    assert_selector "h1", text: "Organization One"
    screenshot("organization-visit-team-index")
  end

  test "inviting an organization member" do
    visit organization_organization_users_url(@organization)
    click_on "Sign in"
    fill_in "user[email]", with: @editor.email
    fill_in "user[password]", with: "password"
    click_form_submit

    screenshot("organization-invite-member")
    click_on "Invite member"
    fill_in "organization_user[invite_email]", with: "viewer_invite@example.com"
    # fill_in "organization_user[review_role]", with: @organization_user.review_role
    # fill_in "organization_user[editor]", with: @organization_user.editor
    screenshot("organization-invite-member")
    click_on "Send invitation"

    assert_text "Organization member was successfully invited."
    screenshot("organization-invite-member")
  end

  test "updating an organization member" do
    visit organization_organization_users_url(@organization)
    click_on "Sign in"
    fill_in "user[email]", with: @editor.email
    fill_in "user[password]", with: "password"
    click_form_submit

    screenshot("organization-update-member")

    click_on "Actions", match: :first
    click_on "Edit"
    screenshot("organization-update-member")
    select "Principal Reviewer", from: "organization_user[review_role]"
    click_on "Update member"
    assert_text "Organization member was successfully updated."
    screenshot("organization-update-member")
  end

  test "destroying an organization member" do
    visit organization_organization_users_url(@organization)
    click_on "Sign in"
    fill_in "user[email]", with: @editor.email
    fill_in "user[password]", with: "password"
    click_form_submit
    screenshot("organization-remove-member")
    # click_on "Actions", match: :second # The following is emulating this.
    page.all(".dropdown-toggle")[2].click
    screenshot("organization-remove-member")
    page.accept_confirm do
      click_on "Delete"
    end
    assert_text "Organization member was successfully deleted."
    screenshot("organization-remove-member")
  end
end
