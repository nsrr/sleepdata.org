require 'test_helper'

class AgreementEventsControllerTest < ActionController::TestCase
  setup do
    @agreement_event = agreement_events(:one)
    @agreement = agreements(:one)
  end

  # test 'should get index' do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:agreement_events)
  # end

  # test 'should get new' do
  #   get :new
  #   assert_response :success
  # end

  test 'should create agreement comment' do
    skip
    login(users(:admin))
    assert_difference('AgreementEvent.count') do
      post :create, params: { agreement_id: @agreement, agreement_event: { comment: 'I reviewed this data access request.' }, format: 'js' }
    end

    assert_equal 'I reviewed this data access request.', assigns(:agreement_event).agreement_events.last.comment
    assert_redirected_to topic_comment_path(assigns(:topic), assigns(:comment))
  end

  test 'should not create agreement comment as anonymous user' do
    assert_difference('Comment.count', 0) do
      post :create, params: { agreement_id: @agreement, agreement_event: { comment: 'I am not logged in.' } }
    end

    assert_redirected_to new_user_session_path
  end

  # test 'should get show and redirect to specific page and location on topic' do
  #   login(users(:valid))
  #   get :show, topic_id: @comment.topic, id: @comment

  #   assert_not_nil assigns(:topic)
  #   assert_not_nil assigns(:comment)

  #   assert_redirected_to topic_path(assigns(:topic)) + '?page=1#c1'
  # end

  test 'should get edit' do
    skip
    login(users(:valid))
    xhr :get, :edit, agreement_id: @agreement, id: @agreement_event, format: 'js'

    assert_not_nil assigns(:agreement)
    assert_not_nil assigns(:agreement_event)

    assert_template 'edit'
    assert_response :success
  end

  test 'should not get edit as another user' do
    skip
    login(users(:two))
    xhr :get, :edit, agreement_id: @agreement, id: @agreement_event, format: 'js'

    assert_not_nil assigns(:agreement)
    assert_nil assigns(:agreement_event)
    assert_response :success
  end

  test 'should update comment' do
    skip
    login(users(:valid))
    patch :update, agreement_id: @agreement, id: @agreement_event, agreement_event: { comment: 'Updated Description' }, format: 'js'

    assert_not_nil assigns(:agreement)
    assert_not_nil assigns(:agreement_event)
    assert_equal 'Updated Description', assigns(:agreement_event).comment

    assert_template 'show'
    assert_response :success
  end

  test 'should not update as another user' do
    skip
    login(users(:two))
    patch :update, agreement_id: @agreement, id: @agreement_event, agreement_event: { comment: 'Updated Description' }

    assert_not_nil assigns(:agreement)
    assert_nil assigns(:agreement_event)

    assert_redirected_to reviews_path # TODO?
  end

  test 'should destroy comment as system admin' do
    skip
    login(users(:admin))
    assert_difference('AgreementEvent.current.count', -1) do
      delete :destroy, agreement_id: @agreement, id: @agreement_event
    end
    assert_not_nil assigns(:agreement)
    assert_redirected_to agreement_agreement_event_path(assigns(:agreement), assigns(:agreement_event))
  end

  test 'should destroy comment as comment author' do
    skip
    login(users(:valid))
    assert_difference('AgreementEvent.current.count', -1) do
      delete :destroy, agreement_id: @agreement, id: @agreement_event
    end

    assert_not_nil assigns(:agreement)

    assert_redirected_to agreement_agreement_event_path(assigns(:agreement), assigns(:agreement_event))
  end

  test 'should not destroy comment as another user' do
    login(users(:two))
    assert_difference('AgreementEvent.current.count', 0) do
      delete :destroy, params: { agreement_id: @agreement, id: @agreement_event }
    end

    assert_redirected_to reviews_path
  end

  test 'should not destroy comment as anonymous user' do
    assert_difference('AgreementEvent.current.count', 0) do
      delete :destroy, params: { agreement_id: @agreement, id: @agreement_event }
    end

    assert_redirected_to new_user_session_path
  end
end
