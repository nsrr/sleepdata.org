require "application_system_test_case"

class FoldersTest < ApplicationSystemTestCase
  setup do
    @folder = folders(:about)
    @admin = users(:admin)
  end

  test "visiting the index" do
    visit admin_folders_url
    sign_in_with_attestation_user_form @admin, password: "password"

    visit admin_folders_url
    screenshot("folders-index")
    assert_selector "h1", text: "Folders"
  end

  test "creating a folder" do
    visit admin_folders_url
    sign_in_with_attestation_user_form @admin, password: "password"

    visit admin_folders_url
    click_on "New Folder"

    fill_in "folder[name]", with: "Webinars"
    fill_in "folder[position]", with: "2"
    first("#folder_displayed", visible: :all).check

    click_on "Create Folder"

    assert_text "Folder was successfully created"
  end

  test "updating a folder" do
    visit admin_folders_url
    sign_in_with_attestation_user_form @admin, password: "password"

    visit admin_folders_url
    click_on "Actions", match: :first
    click_on "Edit", match: :first
    
    fill_in "folder[name]", with: @folder.name
    fill_in "folder[slug]", with: @folder.slug
    fill_in "folder[position]", with: @folder.position
    first("#folder_displayed", visible: :all).check
    click_on "Update Folder"

    assert_text "Folder was successfully updated"
  end

  test "destroying a folder" do
    visit admin_folders_url
    sign_in_with_attestation_user_form @admin, password: "password"
    visit admin_folders_url

    click_on "Actions", match: :first
    page.accept_confirm do
      click_on "Delete", match: :first
    end

    assert_text "Folder was successfully deleted"
  end
end
