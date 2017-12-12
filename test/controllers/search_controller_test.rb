# frozen_string_literal: true

require "test_helper"

# Tests to assure that search results are returned.
class SearchControllerTest < ActionController::TestCase
  test "should get index" do
    skip
    get :index
    assert_response :success
  end
end
