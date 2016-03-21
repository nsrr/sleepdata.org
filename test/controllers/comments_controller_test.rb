# frozen_string_literal: true

require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  setup do
    @comment = comments(:one)
    @topic = topics(:one)
  end

  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:comments)
  # end

  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end

  test "should create comment and not update existing subscription" do
    login(users(:two))
    assert_difference('Comment.count') do
      post :create, topic_id: @topic, comment: { description: "This is my contribution to the discussion." }
    end

    assert_equal "This is my contribution to the discussion.", assigns(:topic).comments.last.description
    assert_not_nil assigns(:topic).last_comment_at
    assert_equal false, assigns(:topic).subscribed?(users(:two))

    assert_redirected_to topic_comment_path(assigns(:topic), assigns(:comment))
  end

  test "should create comment and add subscription" do
    login(users(:admin))
    assert_difference('Comment.count') do
      post :create, topic_id: @topic, comment: { description: "With this comment I'm subscribing to the discussion." }
    end

    assert_equal "With this comment I'm subscribing to the discussion.", assigns(:topic).comments.last.description
    assert_not_nil assigns(:topic).last_comment_at
    assert_equal true, assigns(:topic).subscribed?(users(:admin))

    assert_redirected_to topic_comment_path(assigns(:topic), assigns(:comment))
  end

  test "should not create comment as anonymous user" do
    assert_difference('Comment.count', 0) do
      post :create, topic_id: @topic, comment: { description: "I'm not logged in." }
    end

    assert_redirected_to new_user_session_path
  end

  test "should not create comment as banned user" do
    login(users(:banned))
    assert_difference('Comment.count', 0) do
      post :create, topic_id: @topic, comment: { description: "I'm banned from creating comments." }
    end

    assert_not_nil assigns(:topic)
    assert_nil assigns(:comment)

    assert_redirected_to assigns(:topic)
  end

  test "should not create comment on locked topic" do
    login(users(:valid))
    assert_difference('Comment.count', 0) do
      post :create, topic_id: topics(:locked), comment: { description: "Adding a comment to a locked topic." }
    end

    assert_redirected_to topics_path
  end

  test "should get show and redirect to specific page and location on topic" do
    login(users(:valid))
    get :show, topic_id: @comment.topic, id: @comment

    assert_not_nil assigns(:topic)
    assert_not_nil assigns(:comment)

    assert_redirected_to topic_path(assigns(:topic)) + "?page=1#c1"
  end

  test "should get edit" do
    login(users(:valid))
    xhr :get, :edit, topic_id: @comment.topic_id, id: @comment, format: 'js'

    assert_not_nil assigns(:topic)
    assert_not_nil assigns(:comment)

    assert_template 'edit'
    assert_response :success
  end

  test "should not get edit for comment on locked topic" do
    login(users(:valid))
    xhr :get, :edit, topic_id: topics(:locked), id: comments(:three), format: 'js'

    assert_nil assigns(:topic)
    assert_nil assigns(:comment)

    assert_response :success
  end

  test "should not get edit as another user" do
    login(users(:two))
    xhr :get, :edit, topic_id: @comment.topic_id, id: @comment, format: 'js'

    assert_not_nil assigns(:topic)
    assert_nil assigns(:comment)

    assert_response :success
  end

  test "should not get edit as banned user" do
    login(users(:banned))
    xhr :get, :edit, topic_id: comments(:banned).topic, id: comments(:banned), format: 'js'

    assert_not_nil assigns(:topic)
    assert_nil assigns(:comment)

    assert_response :success
  end

  test "should update comment" do
    login(users(:valid))
    patch :update, topic_id: @comment.topic_id, id: @comment, comment: { description: "Updated Description" }

    assert_not_nil assigns(:topic)
    assert_not_nil assigns(:comment)
    assert_equal "Updated Description", assigns(:comment).description

    assert_equal true, assigns(:topic).subscribed?(users(:valid))

    assert_redirected_to topic_comment_path(assigns(:topic), assigns(:comment))
  end

  test "should update comment but not reset subscription" do
    login(users(:two))
    patch :update, topic_id: comments(:two).topic_id, id: comments(:two), comment: { description: "Updated Description" }

    assert_not_nil assigns(:topic)
    assert_not_nil assigns(:comment)
    assert_equal "Updated Description", assigns(:comment).description

    assert_equal false, assigns(:topic).subscribed?(users(:two))

    assert_redirected_to topic_comment_path(assigns(:topic), assigns(:comment))
  end

  test "should not update comment on locked topic" do
    login(users(:valid))
    patch :update, topic_id: topics(:locked), id: comments(:three), comment: { description: "Updated Description on Locked" }

    assert_nil assigns(:topic)
    assert_nil assigns(:comment)

    assert_redirected_to topics_path
  end

  test "should not update comment as banned user" do
    login(users(:banned))
    patch :update, topic_id: comments(:banned).topic, id: comments(:banned), comment: { description: "I was banned so I'm changing my comment" }

    assert_not_nil assigns(:topic)
    assert_nil assigns(:comment)

    assert_redirected_to assigns(:topic)
  end

  test "should not update as another user" do
    login(users(:two))
    patch :update, topic_id: @comment.topic_id, id: @comment, comment: { description: "Updated Description" }

    assert_not_nil assigns(:topic)
    assert_nil assigns(:comment)

    assert_redirected_to topics_path
  end

  test "should destroy comment as system admin" do
    login(users(:admin))
    assert_difference('Comment.current.count', -1) do
      delete :destroy, topic_id: @comment.topic, id: @comment
    end

    assert_not_nil assigns(:topic)

    assert_redirected_to topic_comment_path(assigns(:topic), assigns(:comment))
  end

  test "should destroy comment as comment author" do
    login(users(:valid))
    assert_difference('Comment.current.count', -1) do
      delete :destroy, topic_id: @comment.topic, id: @comment
    end

    assert_not_nil assigns(:topic)

    assert_redirected_to topic_comment_path(assigns(:topic), assigns(:comment))
  end

  test "should not destroy comment as another user" do
    login(users(:two))
    assert_difference('Comment.current.count', 0) do
      delete :destroy, topic_id: @comment.topic, id: @comment
    end

    assert_redirected_to topics_path
  end

  test "should not destroy comment as anonymous user" do
    assert_difference('Comment.current.count', 0) do
      delete :destroy, topic_id: @comment.topic, id: @comment
    end

    assert_redirected_to new_user_session_path
  end

end
