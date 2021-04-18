# frozen_string_literal: true

require "test_helper"

# Tests to assure that dataset editors can modify datasets.
class Editor::DatasetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dataset = datasets(:released)
    @editor = users(:editor)
  end

  def new_dataset_params
    {
      organization_id: organizations(:one).id,
      name: "New Dataset",
      description: @dataset.description,
      logo: fixture_file_upload("../../support/images/rails.png"),
      released: true,
      slug: "new-dataset",
      release_date: "2014-06-23",
      featured: "1"
    }
  end

  def dataset_params
    {
      name: "We Care",
      slug: @dataset.slug,
      description: @dataset.description,
      released: @dataset.released
    }
  end

  test "should get data requests" do
    login(@editor)
    get data_requests_dataset_url(@dataset)
    assert_response :success
  end

  test "should get audits" do
    login(@editor)
    get audits_dataset_url(@dataset)
    assert_not_nil assigns(:audits)
    assert_response :success
  end

  test "should get page views" do
    login(@editor)
    get page_views_dataset_url(@dataset)
    assert_response :success
  end

  test "should create access role to dataset" do
    login(@editor)
    assert_difference("DatasetUser.count") do
      post create_access_dataset_url(@dataset), params: {
        user_email: "#{users(:aug).full_name} [#{users(:aug).email}]",
        role: "editor"
      }
    end
    assert_not_nil assigns(:dataset_user)
    assert_equal "editor", assigns(:dataset_user).role
    assert_equal users(:aug), assigns(:dataset_user).user
    assert_redirected_to collaborators_dataset_url(assigns(:dataset), dataset_user_id: assigns(:dataset_user).id)
  end

  test "should find existing access when creating access request to dataset" do
    login(@editor)
    assert_difference("DatasetUser.count", 0) do
      post create_access_dataset_url(@dataset), params: {
        user_email: "#{users(:reviewer_on_released).full_name} [#{users(:reviewer_on_released).email}]",
        role: "reviewer"
      }
    end
    assert_not_nil assigns(:dataset_user)
    assert_nil assigns(:dataset_user).approved
    assert_equal "reviewer", assigns(:dataset_user).role
    assert_equal users(:reviewer_on_released), assigns(:dataset_user).user
    assert_redirected_to collaborators_dataset_url(assigns(:dataset), dataset_user_id: assigns(:dataset_user).id)
  end

  test "should show collaborators to editor" do
    login(@editor)
    get collaborators_dataset_url(@dataset)
    assert_response :success
  end

  test "should reset index as editor" do
    login(@editor)
    post reset_index_dataset_url(datasets(:released), path: nil)
    assert_redirected_to files_dataset_url(assigns(:dataset), path: "")
  end

  test "should not reset index as viewer" do
    login(users(:valid))
    post reset_index_dataset_url(datasets(:released), path: nil)
    assert_redirected_to datasets_url
  end

  test "should not reset index as anonymous" do
    post reset_index_dataset_url(datasets(:released), path: nil)
    assert_redirected_to new_user_session_url
  end

  test "should set file as public as editor" do
    login(@editor)
    assert_difference("DatasetFile.where(publicly_available: true).count") do
      post set_public_file_dataset_url(
        datasets(:released),
        path: "NOT_PUBLIC_YET.txt",
        format: "js"
      ), params: {
        public: "1"
      }
    end
    assert_template "set_public_file"
    assert_response :success
  end

  test "should set file as private as editor" do
    login(@editor)
    assert_difference("DatasetFile.where(publicly_available: true).count", -1) do
      post set_public_file_dataset_url(
        datasets(:released),
        path: dataset_files(:released_public_file_txt).full_path,
        format: "js"
      ), params: {
        public: "0"
      }
    end
    assert_template "set_public_file"
    assert_response :success
  end

  test "should set file in subfolder as public as editor" do
    login(@editor)
    assert_difference("DatasetFile.where(publicly_available: true).count") do
      post set_public_file_dataset_url(
        datasets(:released),
        path: "subfolder/IN_SUBFOLDER_NOT_PUBLIC_YET.txt",
        format: "js"
      ), params: {
        public: "1"
      }
    end
    assert_template "set_public_file"
    assert_response :success
  end

  test "should set file in subfolder as private as editor" do
    login(@editor)
    assert_difference("DatasetFile.where(publicly_available: true).count", -1) do
      post set_public_file_dataset_url(
        datasets(:released),
        path: "subfolder/IN_SUBFOLDER_PUBLIC_FILE.txt",
        format: "js"
      ), params: {
        public: "0"
      }
    end
    assert_template "set_public_file"
    assert_response :success
  end

  test "should not set file as public as viewer" do
    login(users(:valid))
    assert_difference("DatasetFile.where(publicly_available: true).count", 0) do
      post set_public_file_dataset_url(
        datasets(:released),
        path: "NOT_PUBLIC_YET.txt",
        format: "js"
      ), params: {
        public: "1"
      }
    end
    assert_template nil
    assert_response :success
  end

  test "should not set file as public as anonymous" do
    assert_difference("DatasetFile.where(publicly_available: true).count", 0) do
      post set_public_file_dataset_url(
        datasets(:released),
        path: "NOT_PUBLIC_YET.txt",
        format: "js"
      ), params: {
        public: "1"
      }
    end
    assert_template nil
    assert_response :unauthorized
  end

  test "should get sync" do
    login(@editor)
    get sync_dataset_url(@dataset)
    assert_response :success
  end

  test "should get settings" do
    login(@editor)
    get settings_dataset_url(@dataset)
    assert_response :success
  end

  test "should pull changes" do
    login(@editor)
    post pull_changes_dataset_url(@dataset)
    assert_redirected_to sync_dataset_url(@dataset)
  end

  test "should get new" do
    login(@editor)
    get new_dataset_url
    assert_response :success
  end

  test "should create dataset" do
    login(@editor)
    assert_difference("Dataset.count") do
      post datasets_url, params: { dataset: new_dataset_params }
    end
    assert_redirected_to dataset_url(assigns(:dataset))
  end

  test "should not create dataset as anonymous user" do
    assert_difference("Dataset.count", 0) do
      post datasets_url, params: { dataset: new_dataset_params }
    end
    assert_redirected_to new_user_session_url
  end

  test "should not create dataset as regular user" do
    login(users(:valid))
    assert_difference("Dataset.count", 0) do
      post datasets_url, params: { dataset: new_dataset_params }
    end
    assert_redirected_to datasets_url
  end

  test "should not create dataset with blank name" do
    login(@editor)
    assert_difference("Dataset.count", 0) do
      post datasets_url, params: { dataset: new_dataset_params.merge(name: "") }
    end
    assert_equal ["can't be blank"], assigns(:dataset).errors[:name]
    assert_template "new"
  end

  test "should not create dataset existing slug" do
    login(@editor)
    assert_difference("Dataset.count", 0) do
      post datasets_url, params: { dataset: new_dataset_params.merge(slug: "released") }
    end
    assert_equal ["has already been taken"], assigns(:dataset).errors[:slug]
    assert_template "new"
  end

  test "should get edit" do
    login(@editor)
    get edit_dataset_url(@dataset)
    assert_response :success
  end

  test "should update dataset" do
    login(@editor)
    patch dataset_url(@dataset), params: {
      dataset: dataset_params.merge(name: "We Care Name Updated")
    }
    @dataset.reload
    assert_equal @dataset.name, "We Care Name Updated"
    assert_redirected_to settings_dataset_url(@dataset)
  end

  test "should not update dataset with blank name" do
    login(@editor)
    patch dataset_url(@dataset), params: {
      dataset: dataset_params.merge(name: "")
    }
    assert_equal ["can't be blank"], assigns(:dataset).errors[:name]
    assert_template "edit"
    assert_response :success
  end

  test "should not update dataset with existing slug" do
    login(@editor)
    patch dataset_url(@dataset), params: {
      dataset: dataset_params.merge(slug: "unreleased")
    }
    assert_equal ["has already been taken"], assigns(:dataset).errors[:slug]
    assert_template "edit"
    assert_response :success
  end

  test "should destroy dataset" do
    login(@editor)
    assert_difference("Dataset.current.count", -1) do
      delete dataset_url(@dataset)
    end
    assert_redirected_to datasets_url
  end
end
