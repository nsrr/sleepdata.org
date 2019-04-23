# frozen_string_literal: true

require "test_helper"

# Test to make sure blog is publicly accessible
class BlogControllerTest < ActionDispatch::IntegrationTest
  setup do
    @community_manager = users(:community_manager)
  end

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

  test "should show draft blog to community manager" do
    login(@community_manager)
    get blog_slug_url(broadcasts(:draft).slug)
    assert_response :success
  end

  test "should get published blog cover" do
    get blog_cover_url(broadcasts(:published).slug)
    assert_equal File.binread(assigns(:broadcast).cover.path), response.body
  end
end
