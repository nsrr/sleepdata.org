# frozen_string_literal: true

require "test_helper"

# Tests to view member profiles.
class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular = users(:regular)
  end

  test "should get index and redirect to forums" do
    get members_url
    assert_redirected_to topics_url
  end

  test "should get show" do
    get member_url(@regular.username)
    assert_redirected_to posts_member_url(@regular.username)
  end

  test "should not show without member" do
    get member_url("DNE")
    assert_redirected_to members_url
  end

  test "should get posts" do
    get posts_member_url(@regular.username)
    assert_response :success
  end

  test "should get tools" do
    get tools_member_url(@regular.username)
    assert_response :success
  end

  test "should get member profile picture with username" do
    get profile_picture_member_url(users(:regular2).username)
    assert_not_nil response
    assert_kind_of String, response.body
    assert_equal File.binread(users(:regular2).profile_picture.thumb.path), response.body
  end
end
