# frozen_string_literal: true

require "test_helper"

# Tests to assure that variables can be viewed.
class VariablesControllerTest < ActionController::TestCase
  setup do
    @dataset = datasets(:public)
    @variable = datasets(:public).variables.first
  end

  test "should get index for public dataset" do
    get :index, params: { dataset_id: @dataset }
    assert_not_nil assigns(:dataset)
    assert_not_nil assigns(:variables)
    assert_response :success
  end

  test "should show public variable to public user" do
    get :show, params: { id: @variable, dataset_id: @dataset }
    assert_not_nil assigns(:dataset)
    assert_not_nil assigns(:variable)
    assert_response :success
  end

  test "should show public variable to logged in user" do
    login(users(:valid))
    get :show, params: { id: @variable, dataset_id: @dataset }
    assert_not_nil assigns(:dataset)
    assert_not_nil assigns(:variable)
    assert_response :success
  end

  test "should show private variable to logged in user" do
    login(users(:admin))
    get :show, params: { id: variables(:private), dataset_id: datasets(:private) }
    assert_not_nil assigns(:dataset)
    assert_not_nil assigns(:variable)
    assert_response :success
  end

  test "should redirect to public dataset for unknown variable" do
    get :show, params: { id: "notavariable", dataset_id: @dataset }
    assert_not_nil assigns(:dataset)
    assert_nil assigns(:variable)
    assert_redirected_to dataset_variables_path(assigns(:dataset))
  end

  test "should not show private variable to public user" do
    get :show, params: { id: variables(:private), dataset_id: datasets(:private) }
    assert_nil assigns(:dataset)
    assert_nil assigns(:variable)
    assert_redirected_to datasets_path
  end

  test "should not show private variable to logged in user" do
    login(users(:valid))
    get :show, params: { id: variables(:private), dataset_id: datasets(:private) }
    assert_nil assigns(:dataset)
    assert_nil assigns(:variable)
    assert_redirected_to datasets_path
  end

  test "should show public variable graphs to public user" do
    get :graphs, params: { id: @variable, dataset_id: @dataset }
    assert_not_nil assigns(:dataset)
    assert_not_nil assigns(:variable)
    assert_response :success
  end

  test "should show public variable history to public user" do
    get :history, params: { id: @variable, dataset_id: @dataset }
    assert_not_nil assigns(:dataset)
    assert_not_nil assigns(:variable)
    assert_response :success
  end

  test "should show public variable known_issues to public user" do
    get :known_issues, params: { id: @variable, dataset_id: @dataset }
    assert_not_nil assigns(:dataset)
    assert_not_nil assigns(:variable)
    assert_response :success
  end

  test "should show public variable related to public user" do
    get :related, params: { id: @variable, dataset_id: @dataset }
    assert_not_nil assigns(:dataset)
    assert_not_nil assigns(:variable)
    assert_response :success
  end
end
