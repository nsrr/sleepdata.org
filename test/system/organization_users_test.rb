require "application_system_test_case"

class OrganizationUsersTest < ApplicationSystemTestCase
  setup do
    @organization_user = organization_users(:one)
  end

  test "visiting the index" do
    visit organization_users_url
    assert_selector "h1", text: "Organization Users"
  end

  test "creating a Organization user" do
    visit organization_users_url
    click_on "New Organization User"

    fill_in "Creator", with: @organization_user.creator_id
    fill_in "Editor", with: @organization_user.editor
    fill_in "Invite Email", with: @organization_user.invite_email
    fill_in "Invite Token", with: @organization_user.invite_token
    fill_in "Organization", with: @organization_user.organization_id
    fill_in "Review Role", with: @organization_user.review_role
    fill_in "User", with: @organization_user.user_id
    click_on "Create Organization user"

    assert_text "Organization user was successfully created"
    click_on "Back"
  end

  test "updating a Organization user" do
    visit organization_users_url
    click_on "Edit", match: :first

    fill_in "Creator", with: @organization_user.creator_id
    fill_in "Editor", with: @organization_user.editor
    fill_in "Invite Email", with: @organization_user.invite_email
    fill_in "Invite Token", with: @organization_user.invite_token
    fill_in "Organization", with: @organization_user.organization_id
    fill_in "Review Role", with: @organization_user.review_role
    fill_in "User", with: @organization_user.user_id
    click_on "Update Organization user"

    assert_text "Organization user was successfully updated"
    click_on "Back"
  end

  test "destroying a Organization user" do
    visit organization_users_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Organization user was successfully destroyed"
  end
end
