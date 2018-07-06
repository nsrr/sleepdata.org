# frozen_string_literal: true

require "test_helper"

# Tests to assure that variables can be viewed.
class VariablesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dataset = datasets(:released)
    @variable = datasets(:released).variables.first
  end

  test "should get index for public dataset" do
    get dataset_variables_url(@dataset)
    assert_response :success
  end

  test "should show public variable to public user" do
    get dataset_variable_url(@dataset, @variable)
    assert_response :success
  end

  test "should show public variable to logged in user" do
    login(users(:valid))
    get dataset_variable_url(@dataset, @variable)
    assert_response :success
  end

  test "should show unreleased variable to logged in user" do
    login(users(:admin))
    get dataset_variable_url(datasets(:unreleased), variables(:private))
    assert_response :success
  end

  test "should redirect to public dataset for unknown variable" do
    get dataset_variable_url(@dataset, "notavariable")
    assert_redirected_to dataset_variables_url(assigns(:dataset))
  end

  test "should not show unreleased variable to public user" do
    get dataset_variable_url(datasets(:unreleased), variables(:private))
    assert_redirected_to datasets_url
  end

  test "should not show unreleased variable to logged in user" do
    login(users(:valid))
    get dataset_variable_url(datasets(:unreleased), variables(:private))
    assert_redirected_to datasets_url
  end

  test "should show public variable graphs to public user" do
    get graphs_dataset_variable_url(@dataset, @variable)
    assert_response :success
  end

  test "should show public variable history to public user" do
    get history_dataset_variable_url(@dataset, @variable)
    assert_response :success
  end

  test "should show public variable known_issues to public user" do
    get known_issues_dataset_variable_url(@dataset, @variable)
    assert_response :success
  end

  test "should show public variable related to public user" do
    get related_dataset_variable_url(@dataset, @variable)
    assert_response :success
  end
end
