require 'test_helper'

class VariablesControllerTest < ActionController::TestCase

  setup do
    @dataset = datasets(:public)
    @variable = datasets(:public).variables.first
  end

  test "should get index for public dataset" do
    get :index, dataset_id: @dataset
    assert_not_nil assigns(:dataset)
    # assert_not_nil assigns(:variables)
    assert_response :success
  end

  test "should show public variable to anonymous user" do
    get :show, id: @variable, dataset_id: @dataset
    assert_not_nil assigns(:dataset)
    assert_not_nil assigns(:variable)
    assert_response :success
  end

  test "should show public variable to logged in user" do
    login(users(:valid))
    get :show, id: @variable, dataset_id: @dataset
    assert_not_nil assigns(:dataset)
    assert_not_nil assigns(:variable)
    assert_response :success
  end

  test "should show private variable to logged in user" do
    login(users(:admin))
    get :show, id: variables(:private), dataset_id: datasets(:private)
    assert_not_nil assigns(:dataset)
    assert_not_nil assigns(:variable)
    assert_response :success
  end

  test "should redirect to public dataset for unknown variable" do
    get :show, id: 'notavariable', dataset_id: @dataset
    assert_not_nil assigns(:dataset)
    assert_nil assigns(:variable)
    assert_redirected_to dataset_variables_path(assigns(:dataset))
  end

  test "should not show private variable to anonymous user" do
    get :show, id: variables(:private), dataset_id: datasets(:private)
    assert_nil assigns(:dataset)
    assert_nil assigns(:variable)
    assert_redirected_to datasets_path
  end

  test "should not show private variable to logged in user" do
    login(users(:valid))
    get :show, id: variables(:private), dataset_id: datasets(:private)
    assert_nil assigns(:dataset)
    assert_nil assigns(:variable)
    assert_redirected_to datasets_path
  end

  test "should get variable chart for public dataset" do
    get :image, id: 'gender', dataset_id: @dataset
    assert_kind_of String, response.body
    assert_equal File.binread( File.join(assigns(:dataset).root_folder, 'dd', 'images', '0.1.0', 'gender.png') ), response.body
  end

  test "should not get non-existent variable chart for public dataset" do
    get :image, id: 'where-is-gender', dataset_id: @dataset
    assert_response :success
  end


end
