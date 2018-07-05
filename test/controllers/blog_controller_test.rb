# frozen_string_literal: true

require "test_helper"

# Test to make sure blog is publicly accessible
class BlogControllerTest < ActionDispatch::IntegrationTest
  test "should get blog" do
    get blog_url
    assert_response :success
  end

  test "should get blog atom feed" do
    get blog_url(format: "atom")
    assert_response :success
  end

  test "should show published blog" do
    get blog_slug_url(broadcasts(:published).slug)
    assert_response :success
  end

  test "should not show draft blog" do
    get blog_slug_url(broadcasts(:draft).slug)
    assert_redirected_to blog_url
  end
end
