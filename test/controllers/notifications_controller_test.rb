# frozen_string_literal: true

require "test_helper"

# Test that notifications can be viewed and marked as read.
class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular_user = users(:valid)
  end

  test "should get index" do
    login(@regular_user)
    get notifications_url
    assert_response :success
    assert_not_nil assigns(:notifications)
  end

  test "should get all read index" do
    login(@regular_user)
    get notifications_url(all: "1")
    assert_response :success
    assert_not_nil assigns(:notifications)
  end

  test "should show blog post reply notification" do
    login(@regular_user)
    get notification_url(notifications(:broadcast_reply_one))
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_redirected_to notifications(:broadcast_reply_one).reply
  end

  test "should show forum topic reply notification" do
    login(@regular_user)
    get notification_url(notifications(:topic_reply_one))
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_redirected_to notifications(:topic_reply_one).reply
  end

  test "should show export notification" do
    notification = notifications(:export)
    login(notification.user)
    get notification_url(notification)
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_redirected_to notification.export
  end

  test "should show blank notification and redirect" do
    login(@regular_user)
    get notification_url(notifications(:blank))
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_redirected_to notifications_url
  end

  test "should not show notification without valid id" do
    login(@regular_user)
    get notification_url(id: -1)
    assert_nil assigns(:notification)
    assert_redirected_to notifications_url
  end

  test "should update notification" do
    login(@regular_user)
    patch notification_url(notifications(:broadcast_reply_one), format: "js"), params: { notification: { read: true } }
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_template "show"
    assert_response :success
  end

  test "should mark all as read" do
    login(@regular_user)
    patch mark_all_as_read_notifications_url(broadcast_id: broadcasts(:published).id, format: "js")
    assert_equal 0, @regular_user.notifications.where(broadcast_id: broadcasts(:published), read: false).count
    assert_template "mark_all_as_read"
    assert_response :success
  end

  test "should not mark all as read without broadcast or topic id" do
    login(@regular_user)
    assert_difference("Notification.where(read: false).count", 0) do
      patch mark_all_as_read_notifications_url(format: "js")
    end
    assert_template "mark_all_as_read"
    assert_response :success
  end
end
