# frozen_string_literal: true

require "test_helper"

# Tests to assure that search results are returned.
class SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get search" do
    get search_path
    assert_response :success
  end

  test "should get search for share" do
    get search_path(search: "share")
    assert_response :success
  end

  test "should get search for fair" do
    get search_path(search: "fair")
    assert_response :success
  end

  test "should get search for shhs" do
    get search_path(search: "shhs")
    assert_response :success
  end
end
