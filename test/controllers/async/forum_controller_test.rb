# frozen_string_literal: true

require "test_helper"

# Tests to assure that users can start new topics from forum index.
class Async::ForumControllerTest < ActionDispatch::IntegrationTest
  def setup
    @regular = users(:regular)
  end

  test "should get start new topic for public user" do
    post async_forum_new_topic_url(format: "js")
    # assert_template "new_topic"
    assert_response :success
  end

  test "should get start new topic for regular user" do
    login(@regular)
    post async_forum_new_topic_url(format: "js")
    # assert_template "new_topic"
    assert_response :success
  end

  test "should sign in as user" do
    post async_forum_login_url(format: "js"), params: {
      email: @regular.email, password: "password"
    }
    # assert_template "create"
    assert_response :success
  end

  test "should not sign in as user with incorrect password" do
    post async_forum_login_url(format: "js"), params: {
      email: @regular.email, password: "wrong"
    }
    # assert_template "new"
    assert_response :success
  end
end
