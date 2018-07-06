# frozen_string_literal: true

# TODO: Note: There currently is no dedicated downloads_controller.rb, however
# handling file downloads from datasets combined with data requests needs to be
# separated from simple dataset updates, and makes more sense as its own
# controller.

require "test_helper"

# Tests to assure different access permissions can download approved files.
class DownloadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @controller = DatasetsController.new # TODO: Will get removed when downloads_controller.rb is added
    @released = datasets(:released)
  end

  # Released dataset
  test "should access private files on released dataset with approved data request" do
    login(data_requests(:approved).user)
    get files_dataset_url(@released, path: "ACCESS_REQUIRED.txt", format: "html")
    assert_not_nil assigns(:dataset)
    assert_not_nil response
    assert_kind_of String, response.body
    assert_equal File.read(assigns(:dataset).find_file("ACCESS_REQUIRED.txt")), response.body
  end

  test "should not access private files on released dataset with manually expired data request" do
    login(data_requests(:expired).user)
    get files_dataset_url(@released, path: "ACCESS_REQUIRED.txt", format: "html")
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_url(@released)
  end

  test "should not access private files on released dataset with automatically expired data request" do
    login(data_requests(:approved_that_expired).user)
    get files_dataset_url(@released, path: "ACCESS_REQUIRED.txt", format: "html")
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_url(@released)
  end

  test "should not access private files on released dataset with submitted data request" do
    login(data_requests(:submitted).user)
    get files_dataset_url(@released, path: "ACCESS_REQUIRED.txt", format: "html")
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_url(@released)
  end

  test "should not access private files on released dataset with started data request" do
    login(data_requests(:started).user)
    get files_dataset_url(@released, path: "ACCESS_REQUIRED.txt", format: "html")
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_url(@released)
  end

  test "should not access private files on released dataset with resubmit data request" do
    login(data_requests(:resubmit).user)
    get files_dataset_url(@released, path: "ACCESS_REQUIRED.txt", format: "html")
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_url(@released)
  end

  test "should not access private files on released dataset with approved but deleted data request" do
    login(data_requests(:deleted).user)
    get files_dataset_url(@released, path: "ACCESS_REQUIRED.txt", format: "html")
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_url(@released)
  end

  test "should not access private files on released dataset without any data request" do
    login(users(:regular_no_data_requests))
    get files_dataset_url(@released, path: "ACCESS_REQUIRED.txt", format: "html")
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_url(@released)
  end

  test "should list private files on released dataset as public user" do
    get files_dataset_url(@released)
    assert_not_nil assigns(:dataset)
    assert_template partial: "_folder"
    assert_response :success
  end

  # Unreleased dataset

  test "should access private files on unreleased dataset with approved data request" do
    login(data_requests(:approved_unreleased).user)
    get files_dataset_url(datasets(:unreleased), path: "ACCESS_REQUIRED.txt", format: "html")
    assert_not_nil assigns(:dataset)
    assert_not_nil response
    assert_kind_of String, response.body
    assert_equal File.read(assigns(:dataset).find_file("ACCESS_REQUIRED.txt")), response.body
  end

  test "should not access private files on unreleased dataset with approved but manually expired data request" do
    login(data_requests(:approved_unreleased_manually_expired).user)
    get files_dataset_url(datasets(:unreleased), path: "ACCESS_REQUIRED.txt", format: "html")
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_url
  end

  test "should not access private files on unreleased dataset with approved but automatically expired data request" do
    login(data_requests(:approved_unreleased_automatically_expired).user)
    get files_dataset_url(datasets(:unreleased), path: "ACCESS_REQUIRED.txt", format: "html")
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_url
  end

  test "should not access private files on unreleased dataset with submitted data request" do
    login(data_requests(:submitted_unreleased).user)
    get files_dataset_url(datasets(:unreleased), path: "ACCESS_REQUIRED.txt", format: "html")
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_url
  end

  test "should not list private files on unreleased dataset as public user" do
    get files_dataset_url(datasets(:unreleased))
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_url
  end

  # No data access released dataset

  test "should not access private files on no access dataset with approved data request for another dataset" do
    login(data_requests(:approved).user)
    get files_dataset_url(datasets(:released_no_access), path: "ACCESS_REQUIRED.txt", format: "html")
    assert_not_nil assigns(:dataset)
    assert_redirected_to files_dataset_url(assigns(:dataset))
  end

  test "should not access private files on unreleased dataset without any data request" do
    login(users(:regular_no_data_requests))
    get files_dataset_url(datasets(:unreleased), path: "ACCESS_REQUIRED.txt", format: "html")
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_url
  end

  test "should list private files on no access dataset as public user" do
    get files_dataset_url(datasets(:released_no_access))
    assert_not_nil assigns(:dataset)
    assert_template partial: "_folder"
    assert_response :success
  end
end
