# frozen_string_literal: true

require 'test_helper'

# Test that notifications can be viewed and marked as read.
class NotificationsControllerTest < ActionController::TestCase
  setup do
    @regular_user = users(:valid)
  end

  test 'should get index' do
    login(@regular_user)
    get :index
    assert_response :success
    assert_not_nil assigns(:notifications)
  end

  test 'should get all read index' do
    login(@regular_user)
    get :index, params: { all: '1' }
    assert_response :success
    assert_not_nil assigns(:notifications)
  end

  test 'should show blog post reply notification' do
    login(@regular_user)
    get :show, params: { id: notifications(:broadcast_reply_one) }
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_redirected_to notifications(:broadcast_reply_one).reply
  end

  test 'should show forum topic reply notification' do
    login(@regular_user)
    get :show, params: { id: notifications(:topic_reply_one) }
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_redirected_to notifications(:topic_reply_one).reply
  end

  test 'should show blank notification and redirect' do
    login(@regular_user)
    get :show, params: { id: notifications(:blank) }
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_redirected_to notifications_path
  end

  test 'should not show notification without valid id' do
    login(@regular_user)
    get :show, params: { id: -1 }
    assert_nil assigns(:notification)
    assert_redirected_to notifications_path
  end

  test 'should update notification' do
    login(@regular_user)
    patch :update, params: {
      id: notifications(:broadcast_reply_one), notification: { read: true }
    }, format: 'js'
    assert_not_nil assigns(:notification)
    assert_equal true, assigns(:notification).read
    assert_template 'show'
    assert_response :success
  end

  test 'should mark all as read' do
    login(@regular_user)
    patch :mark_all_as_read, params: {
      broadcast_id: broadcasts(:published).id
    }, format: 'js'
    assert_equal 0, @regular_user.notifications.where(broadcast_id: broadcasts(:published), read: false).count
    assert_template 'mark_all_as_read'
    assert_response :success
  end

  test 'should not mark all as read without broadcast or topic id' do
    login(@regular_user)
    assert_difference('Notification.where(read: false).count', 0) do
      patch :mark_all_as_read, format: 'js'
    end
    assert_template 'mark_all_as_read'
    assert_response :success
  end
end
