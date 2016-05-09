# frozen_string_literal: true

require 'test_helper'

# Tests to assure that community members can comment on blog posts.
class BroadcastCommentsControllerTest < ActionController::TestCase
  setup do
    @broadcast_comment = broadcast_comments(:one)
    @regular_user = users(:valid)
  end

  def broadcast_comment_params
    {
      description: @broadcast_comment.description,
      broadcast_comment_id: nil
    }
  end

  # test 'should get index' do
  #   login(@regular_user)
  #   get :index, broadcast_id: @broadcast_comment.broadcast.to_param
  #   assert_response :success
  #   assert_not_nil assigns(:broadcast_comments)
  # end

  # test 'should get new' do
  #   login(@regular_user)
  #   get :new, broadcast_id: @broadcast_comment.broadcast.to_param
  #   assert_response :success
  # end

  test 'should preview broadcast comment description' do
    login(@regular_user)
    post :preview, parent_comment_id: 'root', broadcast_comment_id: 'new', broadcast_comment: broadcast_comment_params, format: 'js'
    assert_template 'preview'
    assert_response :success
  end

  test 'should create broadcast comment' do
    login(@regular_user)
    assert_difference('BroadcastComment.count') do
      post :create, broadcast_id: @broadcast_comment.broadcast.to_param, broadcast_comment: broadcast_comment_params, format: 'js'
    end
    assert_template 'create'
    assert_response :success
  end

  test 'should show broadcast comment' do
    login(@regular_user)
    xhr :get, :show, broadcast_id: @broadcast_comment.broadcast.to_param, id: @broadcast_comment, format: 'js'
    assert_template 'show'
    assert_response :success
  end

  test 'should get edit' do
    login(@regular_user)
    xhr :get, :edit, broadcast_id: @broadcast_comment.broadcast.to_param, id: @broadcast_comment, format: 'js'
    assert_template 'edit'
    assert_response :success
  end

  test 'should update broadcast comment' do
    login(@regular_user)
    patch :update, broadcast_id: @broadcast_comment.broadcast.to_param, id: @broadcast_comment, broadcast_comment: broadcast_comment_params, format: 'js'
    assert_template 'show'
    assert_response :success
  end

  test 'should destroy broadcast comment' do
    login(@regular_user)
    assert_difference('BroadcastComment.current.count', -1) do
      delete :destroy, broadcast_id: @broadcast_comment.broadcast.to_param, id: @broadcast_comment, format: 'js'
    end
    assert_template 'show'
    assert_response :success
  end
end
