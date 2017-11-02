# frozen_string_literal: true

# TODO: Note: There currently is no dedicated documentation_controller.rb, however handling
# file downloads from datasets combined with agreements needs to be separated from
# simple dataset updates, and makes more sense as its own controller.

require "test_helper"

class DocumentationControllerTest < ActionController::TestCase
  setup do
    @controller = DatasetsController.new # Will get removed when documentation_controller.rb is added
    @dataset = datasets(:released)
  end

  # Released dataset

  test "should view documentation on released dataset with approved agreement" do
    login(data_requests(:approved).user)
    get :pages, params: { id: datasets(:released), path: "PUBLICLY_VIEWABLE.md", format: "html" }
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on released dataset with manually expired agreement" do
    login(data_requests(:expired).user)
    get :pages, params: { id: datasets(:released), path: "PUBLICLY_VIEWABLE.md", format: "html" }
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on released dataset with automatically expired agreement" do
    login(data_requests(:approved_that_expired).user)
    get :pages, params: { id: datasets(:released), path: "PUBLICLY_VIEWABLE.md", format: "html" }
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on public documentation dataset with submitted agreement" do
    login(data_requests(:submitted).user)
    get :pages, params: { id: datasets(:released), path: "PUBLICLY_VIEWABLE.md", format: "html" }
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on public documentation dataset with started agreement" do
    login(data_requests(:started).user)
    get :pages, params: { id: datasets(:released), path: "PUBLICLY_VIEWABLE.md", format: "html" }
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on public documentation dataset with resubmit agreement" do
    login(data_requests(:resubmit).user)
    get :pages, params: { id: datasets(:released), path: "PUBLICLY_VIEWABLE.md", format: "html" }
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on public documentation dataset with approved but deleted agreement" do
    login(data_requests(:deleted).user)
    get :pages, params: { id: datasets(:released), path: "PUBLICLY_VIEWABLE.md", format: "html" }
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on public documentation dataset without any agreement" do
    login(users(:regular_no_data_requests))
    get :pages, params: { id: datasets(:released), path: "PUBLICLY_VIEWABLE.md", format: "html" }
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on public documentation dataset as anonymous user" do
    get :pages, params: { id: datasets(:released), path: "PUBLICLY_VIEWABLE.md", format: "html" }
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  # Unreleased dataset

  test "should view documentation on unreleased dataset with approved agreement" do
    login(data_requests(:approved_unreleased).user)
    get :pages, params: { id: datasets(:unreleased), path: "ACCESS_REQUIRED.md", format: "html" }
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should not view documentation on private documentation dataset with manually expired agreement" do
    login(data_requests(:approved_unreleased_manually_expired).user)
    get :pages, params: { id: datasets(:unreleased), path: "ACCESS_REQUIRED.md", format: "html" }
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test "should not view documentation on private documentation dataset with automatically expired agreement" do
    login(data_requests(:approved_unreleased_automatically_expired).user)
    get :pages, params: { id: datasets(:unreleased), path: "ACCESS_REQUIRED.md", format: "html" }
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test "should not view documentation on private documentation dataset with submitted data request" do
    login(data_requests(:submitted_unreleased).user)
    get :pages, params: { id: datasets(:unreleased), path: "ACCESS_REQUIRED.md", format: "html" }
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test "should not view documentation on private documentation dataset without any agreement" do
    login(users(:regular_no_data_requests))
    get :pages, params: { id: datasets(:unreleased), path: "ACCESS_REQUIRED.md", format: "html" }
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  test "should not view documentation on private documentation dataset as anonymous user" do
    get :pages, params: { id: datasets(:unreleased), path: "ACCESS_REQUIRED.md", format: "html" }
    assert_nil assigns(:dataset)
    assert_redirected_to datasets_path
  end

  # No data access released dataset

  test "should view documentation on no access dataset without any agreement" do
    login(users(:regular_no_data_requests))
    get :pages, params: { id: datasets(:released_no_access), path: "PUBLICLY_VIEWABLE.md", format: "html" }
    assert_not_nil assigns(:dataset)
    assert_response :success
  end

  test "should view documentation on no access dataset as anonymous user" do
    get :pages, params: { id: datasets(:released_no_access), path: "PUBLICLY_VIEWABLE.md", format: "html" }
    assert_not_nil assigns(:dataset)
    assert_response :success
  end
end
