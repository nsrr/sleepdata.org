# frozen_string_literal: true

require 'test_helper'

# Tests to assure that members can reply to blog posts and forum topics.
class RepliesControllerTest < ActionController::TestCase
  setup do
    @reply = replies(:one)
    @regular_user = users(:valid)
  end

  def reply_params
    {
      description: @reply.description,
      reply_id: nil
    }
  end

  # test 'should get index' do
  #   login(@regular_user)
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:replies)
  # end

  # test 'should get new' do
  #   login(@regular_user)
  #   get :new
  #   assert_response :success
  # end

  test 'should preview reply' do
    login(@regular_user)
    post :preview, params: {
      parent_comment_id: 'root', reply_id: 'new', reply: reply_params
    }, format: 'js'
    assert_template 'preview'
    assert_response :success
  end

  test 'should create reply to forum topic' do
    login(@regular_user)
    assert_difference('Reply.count') do
      post :create, params: {
        topic_id: topics(:one).to_param, reply: reply_params
      }, format: 'js'
    end
    assert_template 'create'
    assert_response :success
  end

  # TODO: Should add test to reply to blog post.
  test 'should create reply to blog post' do
    skip
    login(@regular_user)
    assert_difference('Reply.count') do
      post :create, params: {
        broadcast_id: broadcasts(:one).to_param, reply: reply_params
      }, format: 'js'
    end
    assert_template 'create'
    assert_response :success
  end

  test 'should show reply to a forum topic and redirect to correct page' do
    login(@regular_user)
    get :show, params: { id: @reply }
    assert_redirected_to page_topic_path(@reply.topic, page: @reply.page, anchor: @reply.anchor)
  end

  # TODO: Add a redirect for a reply on a blog post.
  test 'should show reply to a blog post and redirect to correct page' do
    skip
    login(@regular_user)
    get :show, params: { id: @reply_blog_post }
    assert_redirected_to page_broadcast_path(@reply_blog_post.broadcast, page: @reply_blog_post.page, anchor: @reply_blog_post.anchor)
  end

  test 'should show reply' do
    login(@regular_user)
    get :show, params: { id: @reply }, xhr: true, format: 'js'
    assert_template 'show'
    assert_response :success
  end

  test 'should get edit' do
    login(@regular_user)
    get :edit, params: { id: @reply }, xhr: true, format: 'js'
    assert_template 'edit'
    assert_response :success
  end

  test 'should update reply' do
    login(@regular_user)
    patch :update, params: { id: @reply, reply: reply_params }, format: 'js'
    assert_template 'show'
    assert_response :success
  end

  test 'should destroy reply' do
    login(@regular_user)
    assert_difference('Reply.current.count', -1) do
      delete :destroy, params: { id: @reply }, format: 'js'
    end
    assert_template 'show'
    assert_response :success
  end
end

# # frozen_string_literal: true

# require 'test_helper'

# # Tests to assure that members can reply to blog posts and forum topics.
# class RepliesControllerTest < ActionController::TestCase
#   setup do
#     @reply = replies(:one)
#     @topic = topics(:one)
#   end

#   # test 'should get index' do
#   #   get :index
#   #   assert_response :success
#   #   assert_not_nil assigns(:comments)
#   # end

#   # test 'should get new' do
#   #   get :new
#   #   assert_response :success
#   # end

#   test 'should create comment and not update existing subscription' do
#     login(users(:two))
#     assert_difference('Comment.count') do
#       post :create, topic_id: @topic, comment: { description: 'This is my contribution to the discussion.' }
#     end
#     assert_equal 'This is my contribution to the discussion.', assigns(:topic).comments.last.description
#     assert_not_nil assigns(:topic).last_reply_at
#     assert_equal false, assigns(:topic).subscribed?(users(:two))
#     assert_redirected_to topic_comment_path(assigns(:topic), assigns(:comment))
#   end

#   test 'should create comment and add subscription' do
#     login(users(:admin))
#     assert_difference('Comment.count') do
#       post :create, topic_id: @topic, comment: { description: 'With this comment Im subscribing to the discussion.' }
#     end
#     assert_equal 'With this comment Im subscribing to the discussion.', assigns(:topic).comments.last.description
#     assert_not_nil assigns(:topic).last_reply_at
#     assert_equal true, assigns(:topic).subscribed?(users(:admin))
#     assert_redirected_to topic_comment_path(assigns(:topic), assigns(:comment))
#   end

#   test 'should not create comment as anonymous user' do
#     assert_difference('Comment.count', 0) do
#       post :create, topic_id: @topic, comment: { description: 'I am not logged in.' }
#     end
#     assert_redirected_to new_user_session_path
#   end

#   test 'should not create comment as banned user' do
#     login(users(:banned))
#     assert_difference('Comment.count', 0) do
#       post :create, topic_id: @topic, comment: { description: 'I am banned from creating comments.' }
#     end
#     assert_not_nil assigns(:topic)
#     assert_nil assigns(:comment)
#     assert_redirected_to assigns(:topic)
#   end

#   test 'should not create comment on locked topic' do
#     login(users(:valid))
#     assert_difference('Comment.count', 0) do
#       post :create, topic_id: topics(:locked), comment: { description: 'Adding a comment to a locked topic.' }
#     end
#     assert_redirected_to topics_path
#   end

#   test 'should get show and redirect to specific page and location on topic' do
#     login(users(:valid))
#     get :show, topic_id: @comment.topic, id: @comment
#     assert_not_nil assigns(:topic)
#     assert_not_nil assigns(:comment)
#     assert_redirected_to topic_path(assigns(:topic)) + '?page=1#c1'
#   end

#   test 'should get edit' do
#     login(users(:valid))
#     xhr :get, :edit, topic_id: @comment.topic, id: @comment, format: 'js'
#     assert_not_nil assigns(:topic)
#     assert_not_nil assigns(:comment)
#     assert_template 'edit'
#     assert_response :success
#   end

#   test 'should not get edit for comment on locked topic' do
#     login(users(:valid))
#     xhr :get, :edit, topic_id: topics(:locked), id: comments(:three), format: 'js'
#     assert_nil assigns(:topic)
#     assert_nil assigns(:comment)
#     assert_response :success
#   end

#   test 'should not get edit as another user' do
#     login(users(:two))
#     xhr :get, :edit, topic_id: @comment.topic, id: @comment, format: 'js'
#     assert_not_nil assigns(:topic)
#     assert_nil assigns(:comment)
#     assert_response :success
#   end

#   test 'should not get edit as banned user' do
#     login(users(:banned))
#     xhr :get, :edit, topic_id: comments(:banned).topic, id: comments(:banned), format: 'js'
#     assert_not_nil assigns(:topic)
#     assert_nil assigns(:comment)
#     assert_response :success
#   end

#   test 'should update comment' do
#     login(users(:valid))
#     patch :update, topic_id: @comment.topic, id: @comment, comment: { description: 'Updated Description' }
#     assert_not_nil assigns(:topic)
#     assert_not_nil assigns(:comment)
#     assert_equal 'Updated Description', assigns(:comment).description
#     assert_equal true, assigns(:topic).subscribed?(users(:valid))
#     assert_redirected_to topic_comment_path(assigns(:topic), assigns(:comment))
#   end

#   test 'should update comment but not reset subscription' do
#     login(users(:two))
#     patch :update, topic_id: comments(:two).topic, id: comments(:two), comment: { description: 'Updated Description' }
#     assert_not_nil assigns(:topic)
#     assert_not_nil assigns(:comment)
#     assert_equal 'Updated Description', assigns(:comment).description
#     assert_equal false, assigns(:topic).subscribed?(users(:two))
#     assert_redirected_to topic_comment_path(assigns(:topic), assigns(:comment))
#   end

#   test 'should not update comment on locked topic' do
#     login(users(:valid))
#     patch :update, topic_id: topics(:locked), id: comments(:three), comment: { description: 'Updated Description on Locked' }
#     assert_nil assigns(:topic)
#     assert_nil assigns(:comment)
#     assert_redirected_to topics_path
#   end

#   test 'should not update comment as banned user' do
#     login(users(:banned))
#     patch :update, topic_id: comments(:banned).topic, id: comments(:banned), comment: { description: 'I was banned so I m changing my comment' }
#     assert_not_nil assigns(:topic)
#     assert_nil assigns(:comment)
#     assert_redirected_to assigns(:topic)
#   end

#   test 'should not update as another user' do
#     login(users(:two))
#     patch :update, topic_id: @comment.topic, id: @comment, comment: { description: 'Updated Description' }
#     assert_not_nil assigns(:topic)
#     assert_nil assigns(:comment)
#     assert_redirected_to topics_path
#   end

#   test 'should destroy comment as system admin' do
#     login(users(:admin))
#     assert_difference('Comment.current.count', -1) do
#       delete :destroy, topic_id: @comment.topic, id: @comment
#     end
#     assert_not_nil assigns(:topic)
#     assert_redirected_to topic_comment_path(assigns(:topic), assigns(:comment))
#   end

#   test 'should destroy comment as comment author' do
#     login(users(:valid))
#     assert_difference('Comment.current.count', -1) do
#       delete :destroy, topic_id: @comment.topic, id: @comment
#     end
#     assert_not_nil assigns(:topic)
#     assert_redirected_to topic_comment_path(assigns(:topic), assigns(:comment))
#   end

#   test 'should not destroy comment as another user' do
#     login(users(:two))
#     assert_difference('Comment.current.count', 0) do
#       delete :destroy, topic_id: @comment.topic, id: @comment
#     end
#     assert_redirected_to topics_path
#   end

#   test 'should not destroy comment as anonymous user' do
#     assert_difference('Comment.current.count', 0) do
#       delete :destroy, topic_id: @comment.topic, id: @comment
#     end
#     assert_redirected_to new_user_session_path
#   end
# end
