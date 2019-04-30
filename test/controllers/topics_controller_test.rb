# frozen_string_literal: true

require "test_helper"

# Tests to assure that users can view and modify topics.
class TopicsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @topic = topics(:one)
    @admin = users(:admin)
  end

  def topic_params
    {
      title: "New Topic Title",
      slug: "new-topic-title",
      description: "First Reply on New Topic",
      tag_ids: [ActiveRecord::FixtureSet.identify(:meeting)]
    }
  end

  test "should get markup" do
    get markup_topics_url
    assert_response :success
  end

  test "should subscribe to notifications" do
    login(users(:valid))
    post subscription_topic_url(@topic, format: "js"), params: { notify: "1" }
    assert_not_nil assigns(:topic)
    assert_equal true, assigns(:topic).subscribed?(users(:valid))
    assert_template "subscription"
    assert_response :success
  end

  test "should unsubscribe from notifications" do
    login(users(:valid))
    post subscription_topic_url(@topic, format: "js"), params: { notify: "0" }
    assert_not_nil assigns(:topic)
    assert_equal false, assigns(:topic).subscribed?(users(:valid))
    assert_template "subscription"
    assert_response :success
  end

  test "should not subscribe for anonymous user" do
    post subscription_topic_url(@topic, format: "js"), params: { notify: "1" }
    assert_template nil
    assert_response :unauthorized
  end

  test "should get index" do
    get topics_url
    assert_response :success
    assert_not_nil assigns(:topics)
  end

  test "should search index" do
    get topics_url, params: { s: "variable" }
    assert_response :success
    assert_not_nil assigns(:topics)
  end

  test "should get new" do
    login(users(:valid))
    get new_topic_url
    assert_response :success
  end

  test "should create topic" do
    login(users(:valid))
    assert_difference("Reply.count") do
      assert_difference("Topic.count") do
        post topics_url, params: { topic: topic_params }
      end
    end
    assert_not_nil assigns(:topic)
    assert_equal "New Topic Title", assigns(:topic).title
    assert_equal "new-topic-title", assigns(:topic).slug
    assert_equal users(:valid), assigns(:topic).user
    assert_equal "First Reply on New Topic", assigns(:topic).replies.first.description
    assert_equal users(:valid), assigns(:topic).replies.first.user
    assert_not_nil assigns(:topic).last_reply_at
    assert_equal [], assigns(:topic).tags
    assert_equal true, assigns(:topic).subscribed?(users(:valid))
    assert_redirected_to topic_url(assigns(:topic))
  end

  test "should create topic with tags as core member" do
    login(users(:core))
    assert_difference("Topic.count") do
      post topics_url, params: { topic: topic_params }
    end
    assert_not_nil assigns(:topic)
    assert_equal [tags(:meeting)], assigns(:topic).tags
    assert_redirected_to topic_url(assigns(:topic))
  end

  test "should create topic with tags as AUG member" do
    login(users(:aug))
    assert_difference("Topic.count") do
      post topics_url, params: { topic: topic_params }
    end
    assert_not_nil assigns(:topic)
    assert_equal [tags(:meeting)], assigns(:topic).tags
    assert_redirected_to topic_url(assigns(:topic))
  end

  test "should not create topic with blank description" do
    login(users(:valid))
    assert_difference("Reply.count", 0) do
      assert_difference("Topic.count", 0) do
        post topics_url, params: { topic: topic_params.merge(description: "") }
      end
    end
    assert_not_nil assigns(:topic)
    assert_equal ["can't be blank"], assigns(:topic).errors[:description]
    assert_template "new"
    assert_response :success
  end

  test "should show topic" do
    get topic_url(@topic)
    assert_response :success
  end

  test "should show topic without replies" do
    login(users(:valid))
    get topic_url(topics(:without_replies))
    assert_response :success
  end

  test "should not show topic from banned user" do
    skip
    get topic_url(topics(:banned))
    assert_nil assigns(:topic)
    assert_redirected_to topics_url
  end

  test "should show topic to admin" do
    login(@admin)
    get topic_url(@topic)
    assert_response :success
  end

  test "should get edit" do
    login(users(:valid))
    get edit_topic_url(@topic)
    assert_response :success
  end

  test "should not get edit as another user" do
    login(users(:two))
    get edit_topic_url(@topic)
    assert_nil assigns(:topic)
    assert_redirected_to topics_url
  end

  test "should not get edit for locked topic" do
    login(users(:valid))
    get edit_topic_url(topics(:locked))
    assert_nil assigns(:topic)
    assert_redirected_to topics_url
  end

  test "should update topic" do
    login(users(:valid))
    patch topic_url(@topic), params: { topic: topic_params.merge(title: "Updated Topic Title") }
    assert_not_nil assigns(:topic)
    assert_equal "Updated Topic Title", assigns(:topic).title
    assert_redirected_to topic_url(assigns(:topic))
  end

  test "should not update topic with blank title" do
    login(users(:valid))
    patch topic_url(@topic), params: { topic: topic_params.merge(title: "") }
    assert_template "edit"
    assert_response :success
  end

  test "should not update topic as another user" do
    login(users(:two))
    patch topic_url(@topic), params: { topic: topic_params.merge(title: "Updated Topic Title") }
    assert_redirected_to topics_url
  end

  test "should lock topic as admin" do
    login(users(:admin))
    post admin_topic_url(@topic), params: { topic: { locked: "1" } }
    assert_not_nil assigns(:topic)
    assert_equal true, assigns(:topic).locked
    assert_redirected_to topics_url
  end

  test "should not lock topic as regular user" do
    login(users(:valid))
    post admin_topic_url(@topic), params: { topic: { locked: "1" } }
    assert_redirected_to root_url
  end

  test "should not lock topic as public user" do
    post admin_topic_url(@topic), params: { topic: { locked: "1" } }
    assert_redirected_to new_user_session_url
  end

  test "should sticky a topic as admin" do
    login(users(:admin))
    post admin_topic_url(@topic), params: { topic: { pinned: "1" } }
    assert_not_nil assigns(:topic)
    assert_equal true, assigns(:topic).pinned?
    assert_redirected_to topics_url
  end

  test "should not sticky a topic as regular user" do
    login(users(:valid))
    post admin_topic_url(@topic), params: { topic: { pinned: "1" } }
    assert_redirected_to root_url
  end

  test "should not sticky topic as public user" do
    post admin_topic_url(@topic), params: { topic: { pinned: "1" } }
    assert_redirected_to new_user_session_url
  end

  test "should not destroy topic as user" do
    login(users(:valid))
    assert_difference("Topic.current.count", 0) do
      delete topic_url(@topic)
    end
    assert_redirected_to root_url
  end

  test "should destroy topic as admin" do
    login(users(:admin))
    assert_difference("Topic.current.count", -1) do
      delete topic_url(@topic)
    end
    @topic.reload
    assert_nil @topic.slug
    assert_redirected_to topics_url
  end
end
