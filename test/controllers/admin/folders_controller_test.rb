require "test_helper"

# Test that admins can create and edit folders.
class Admin::FoldersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @folder = folders(:about)
    @admin = users(:admin)
  end

  def folder_params
    {
      name: "Learn",
      slug: "learn",
      position: "1",
      displayed: "1"
    }
  end

  test "should get index" do
    login(@admin)
    get admin_folders_url
    assert_response :success
  end

  test "should get new" do
    login(@admin)
    get new_admin_folder_url
    assert_response :success
  end

  test "should create folder" do
    login(@admin)
    assert_difference("Folder.count") do
      post admin_folders_url, params: { folder: folder_params }
    end

    assert_redirected_to admin_folder_url(Folder.last)
  end

  test "should show folder" do
    login(@admin)
    get admin_folder_url(@folder)
    assert_response :success
  end

  test "should get edit" do
    login(@admin)
    get edit_admin_folder_url(@folder)
    assert_response :success
  end

  test "should update folder" do
    login(@admin)
    patch admin_folder_url(@folder), params: { folder: folder_params }
    @folder.reload
    assert_redirected_to admin_folder_url(@folder)
  end

  test "should destroy folder" do
    login(@admin)
    assert_difference("Folder.current.count", -1) do
      delete admin_folder_url(@folder)
    end

    assert_redirected_to admin_folders_url
  end
end
