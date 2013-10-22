require 'test_helper'

class DatasetsControllerTest < ActionController::TestCase
  setup do
    @dataset = datasets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:datasets)
  end

  test "should get new" do
    login(users(:admin))
    get :new
    assert_response :success
  end

  test "should create dataset" do
    login(users(:admin))
    assert_difference('Dataset.count') do
      post :create, dataset: { name: 'New Dataset', description: @dataset.description, logo: fixture_file_upload('../../test/support/datasets/rails.png'), public: true, slug: 'new_dataset' }
    end

    assert_redirected_to dataset_path(assigns(:dataset))
  end

  test "should get manifest" do
    get :manifest, id: @dataset
    assert_response :success
  end

  test "should show dataset" do
    get :show, id: @dataset
    assert_response :success
  end

  test "should get edit" do
    login(users(:admin))
    get :edit, id: @dataset
    assert_response :success
  end

  test "should update dataset" do
    login(users(:admin))
    patch :update, id: @dataset, dataset: { name: 'We Care Name Updated', description: @dataset.description, logo: fixture_file_upload('../../test/support/datasets/rails.png'), public: @dataset.public, slug: @dataset.slug }
    assert_redirected_to dataset_path(assigns(:dataset))
  end

  test "should destroy dataset" do
    login(users(:admin))
    assert_difference('Dataset.current.count', -1) do
      delete :destroy, id: @dataset
    end

    assert_redirected_to datasets_path
  end
end
