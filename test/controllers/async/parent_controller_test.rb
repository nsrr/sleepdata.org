# frozen_string_literal: true

require "test_helper"

# Tests to assure that users can create replies to blog posts and forum topics.
class Async::ParentControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular = users(:regular)
  end

  test "should start new reply on blog post for public user" do
    post async_parent_reply_url(format: "js"), params: {
      broadcast_id: broadcasts(:published).to_param,
      parent_reply_id: "root", reply_id: "new"
    }
    # assert_equal true, assigns(:reply).new_record?
    # assert_equal Broadcast, assigns(:reply).parent.class
    assert_response :success
  end

  test "should start new reply on forum topic for public user" do
    post async_parent_reply_url(format: "js"), params: {
      topic_id: topics(:one).to_param,
      parent_reply_id: "root", reply_id: "new"
    }
    # assert_equal true, assigns(:reply).new_record?
    # assert_equal Topic, assigns(:reply).parent.class
    assert_response :success
  end

  test "should start new reply on blog post for regular user" do
    login(@regular)
    post async_parent_reply_url(format: "js"), params: {
      broadcast_id: broadcasts(:published).to_param,
      parent_reply_id: "root", reply_id: "new"
    }
    assert_response :success
  end

  test "should start new reply on forum topic for regular user" do
    login(@regular)
    post async_parent_reply_url(format: "js"), params: {
      topic_id: topics(:one).to_param, parent_reply_id: "root", reply_id: "new"
    }
    assert_response :success
  end

  test "should sign in as user when replying to blog post" do
    post async_parent_login_url(format: "js"), params: {
      email: @regular.email, password: "password",
      broadcast_id: broadcasts(:published).to_param
    }
    # assert_equal true, assigns(:reply).new_record?
    # assert_equal Broadcast, assigns(:reply).parent.class
    assert_response :success
  end

  test "should sign in as user when replying to forum topic" do
    post async_parent_login_url(format: "js"), params: {
      email: @regular.email, password: "password",
      topic_id: topics(:one).to_param
    }
    # assert_equal true, assigns(:reply).new_record?
    # assert_equal Topic, assigns(:reply).parent.class
    assert_response :success
  end

  test "should not sign in as user with incorrect password when reply to blog post" do
    post async_parent_login_url(format: "js"), params: {
      email: @regular.email, password: "wrong",
      broadcast_id: broadcasts(:published).to_param
    }
    assert_response :success
  end

  test "should not sign in as user with incorrect password when reply to forum topic" do
    post async_parent_login_url(format: "js"), params: {
      email: @regular.email, password: "wrong",
      topic_id: topics(:one).to_param
    }
    assert_response :success
  end
end
