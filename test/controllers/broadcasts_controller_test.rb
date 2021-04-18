# frozen_string_literal: true

require "test_helper"

# Tests to assure that community managers can view and modify blog posts.
class BroadcastsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @broadcast = broadcasts(:draft)
    login(users(:community_manager))
  end

  def broadcast_params
    {
      title: "Broadcast Title",
      slug: "broadcast-title",
      short_description: "This is the short description.",
      keywords: "new article, short description, blog post",
      description: "This is the longer content of the blog post.",
      pinned: "1",
      publish_date: "11/15/2015",
      published: "1",
      archived: "0",
      cover: fixture_file_upload("../../support/images/rails.png")
    }
  end

  test "should get index" do
    get broadcasts_url
    assert_response :success
  end

  test "should get new" do
    get new_broadcast_url
    assert_response :success
  end

  test "should create broadcast" do
    assert_difference("Broadcast.count") do
      post broadcasts_url, params: { broadcast: broadcast_params }
    end
    assert_equal "Broadcast Title", Broadcast.last.title
    assert_equal "This is the short description.", Broadcast.last.short_description
    assert_equal "This is the longer content of the blog post.", Broadcast.last.description
    assert_equal users(:community_manager), Broadcast.last.user
    assert_equal true, Broadcast.last.pinned
    assert_equal true, Broadcast.last.published
    assert_equal false, Broadcast.last.archived
    assert_redirected_to broadcast_url(Broadcast.last)
  end

  test "should not create broadcast with blank title" do
    assert_difference("Broadcast.count", 0) do
      post broadcasts_url, params: { broadcast: broadcast_params.merge(title: "") }
    end
    assert_response :success
  end

  test "should show broadcast" do
    get broadcast_url(@broadcast)
    assert_response :success
  end

  test "should get edit" do
    get edit_broadcast_url(@broadcast)
    assert_response :success
  end

  test "should update broadcast" do
    patch broadcast_url(@broadcast), params: { broadcast: broadcast_params }
    @broadcast.reload
    assert_redirected_to broadcast_url(@broadcast)
  end

  test "should not update broadcast with blank title" do
    patch broadcast_url(@broadcast), params: { broadcast: broadcast_params.merge(title: "") }
    assert_response :success
  end

  test "should destroy broadcast" do
    assert_difference("Broadcast.current.count", -1) do
      delete broadcast_url(@broadcast)
    end
    assert_redirected_to broadcasts_url
  end
end
