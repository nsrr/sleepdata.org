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

  test "should create comment" do
    login(users(:valid))
    assert_difference('Comment.count') do
      post :create, topic_id: @topic, comment: { description: "This is my contribution to the discussion." }
    end

    assert_equal "This is my contribution to the discussion.", assigns(:topic).comments.last.description

    assert_redirected_to topic_path(assigns(:topic))
  end

  test "should not create comment as anonymous user" do
    assert_difference('Comment.count', 0) do
      post :create, topic_id: @topic, comment: { description: "I'm not logged in." }
    end

    assert_redirected_to new_user_session_path
  end

  test "should not create comment on locked topic" do
    login(users(:valid))
    assert_difference('Comment.count', 0) do
      post :create, topic_id: topics(:locked), comment: { description: "Adding a comment to a locked topic." }
    end

    assert_redirected_to topics_path
  end

  # test "should show comment" do
  #   get :show, id: @comment
  #   assert_response :success
  # end

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

  test "should update comment" do
    login(users(:valid))
    patch :update, topic_id: @comment.topic_id, id: @comment, comment: { description: "Updated Description" }

    assert_not_nil assigns(:topic)
    assert_not_nil assigns(:comment)
    assert_equal "Updated Description", assigns(:comment).description

    assert_redirected_to topic_path(assigns(:topic))
  end

  test "should not update comment on locked topic" do
    login(users(:valid))
    patch :update, topic_id: topics(:locked), id: comments(:three), comment: { description: "Updated Description on Locked" }

    assert_nil assigns(:topic)
    assert_nil assigns(:comment)

    assert_redirected_to topics_path
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

    assert_redirected_to assigns(:topic)
  end

  test "should destroy comment as comment author" do
    login(users(:valid))
    assert_difference('Comment.current.count', -1) do
      delete :destroy, topic_id: @comment.topic, id: @comment
    end

    assert_not_nil assigns(:topic)

    assert_redirected_to assigns(:topic)
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
