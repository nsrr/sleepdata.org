# frozen_string_literal: true

require "test_helper"

# Tests to assure that search results are returned.
class SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get search" do
    get search_url
    assert_response :success
  end

  test "should get search for share" do
    get search_url(search: "share")
    assert_response :success
  end

  test "should get search for fair" do
    get search_url(search: "fair")
    assert_response :success
  end

  test "should get search for shhs" do
    get search_url(search: "shhs")
    assert_response :success
  end
end
