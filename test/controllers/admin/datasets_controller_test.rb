# frozen_string_literal: true

require "test_helper"

# Tests to assure that admins can create and delete datasets.
class Admin::DatasetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dataset = datasets(:released)
    @admin = users(:admin)
  end

  def dataset_params
    {
      name: "New Dataset",
      description: @dataset.description,
      logo: fixture_file_upload("../../test/support/images/rails.png"),
      released: true,
      slug: "new-dataset",
      release_date: "2014-06-23"
    }
  end

  test "should get new" do
    login(@admin)
    get new_dataset_url
    assert_response :success
  end

  test "should create dataset" do
    login(@admin)
    assert_difference("Dataset.count") do
      post datasets_url, params: { dataset: dataset_params }
    end
    assert_redirected_to dataset_url(assigns(:dataset))
  end

  test "should not create dataset as anonymous user" do
    assert_difference("Dataset.count", 0) do
      post datasets_url, params: { dataset: dataset_params }
    end
    assert_redirected_to new_user_session_url
  end

  test "should not create dataset as regular user" do
    login(users(:valid))
    assert_difference("Dataset.count", 0) do
      post datasets_url, params: { dataset: dataset_params }
    end
    assert_redirected_to root_url
  end

  test "should not create dataset with blank name" do
    login(@admin)
    assert_difference("Dataset.count", 0) do
      post datasets_url, params: { dataset: dataset_params.merge(name: "") }
    end
    assert_equal ["can't be blank"], assigns(:dataset).errors[:name]
    assert_template "new"
  end

  test "should not create dataset existing slug" do
    login(@admin)
    assert_difference("Dataset.count", 0) do
      post datasets_url, params: { dataset: dataset_params.merge(slug: "released") }
    end
    assert_equal ["has already been taken"], assigns(:dataset).errors[:slug]
    assert_template "new"
  end

  test "should destroy dataset" do
    login(@admin)
    assert_difference("Dataset.current.count", -1) do
      delete dataset_url(@dataset)
    end
    assert_redirected_to datasets_url
  end
end
