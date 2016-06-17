# frozen_string_literal: true

require 'test_helper'

class AgreementEventsControllerTest < ActionController::TestCase
  setup do
    @agreement_event = agreement_events(:one_commented)
    @agreement = agreements(:one)
    @submitted = agreements(:submitted_application)
    @admin = users(:admin)
    @reviewer = users(:reviewer_on_public)
    @reviewer_comment = agreement_events(:reviewer_comment)
    @reviewer_two = users(:reviewer_two_on_public)
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
    login(@reviewer)
    assert_difference('AgreementEvent.count') do
      post :create, agreement_id: @submitted, agreement_event: { comment: 'I reviewed this data access request, cc @reviewer_two_on_public.' }, format: 'js'
    end
    assert_equal 'I reviewed this data access request, cc @reviewer_two_on_public.', assigns(:agreement_event).comment
    assert_template 'create'
    assert_response :success
  end

  test 'should not create blank agreement comment' do
    login(@reviewer)
    assert_difference('AgreementEvent.count', 0) do
      post :create, agreement_id: @submitted, agreement_event: { comment: '' }, format: 'js'
    end
    assert_template 'new'
    assert_response :success
  end

  test 'should not create agreement comment as anonymous user' do
    assert_difference('AgreementEvent.count', 0) do
      post :create, agreement_id: @agreement, agreement_event: { comment: 'I am not logged in.' }, format: 'js'
    end
    assert_template nil
    assert_response :unauthorized
  end

  # test 'should get show and redirect to specific page and location on topic' do
  #   login(users(:valid))
  #   get :show, topic_id: @comment.topic, id: @comment

  #   assert_not_nil assigns(:topic)
  #   assert_not_nil assigns(:comment)

  #   assert_redirected_to topic_path(assigns(:topic)) + '?page=1#c1'
  # end

  test 'should get edit' do
    login(@reviewer)
    xhr :get, :edit, agreement_id: @submitted, id: @reviewer_comment, format: 'js'
    assert_not_nil assigns(:agreement)
    assert_not_nil assigns(:agreement_event)
    assert_template 'edit'
    assert_response :success
  end

  test 'should not get edit as another user' do
    login(@reviewer_two)
    xhr :get, :edit, agreement_id: @submitted, id: @reviewer_comment, format: 'js'
    assert_not_nil assigns(:agreement)
    assert_nil assigns(:agreement_event)
    assert_response :success
  end

  test 'should preview comment' do
    login(@reviewer)
    post :preview, agreement_id: @submitted, agreement_event_id: @reviewer_comment, agreement_event: { comment: 'Preview this for **formatting**.' }, format: 'js'
    assert_template 'preview'
    assert_response :success
  end

  test 'should preview new comment' do
    login(@reviewer)
    post :preview, agreement_id: @submitted, agreement_event: { comment: 'Preview this for **formatting**.' }, format: 'js'
    assert_template 'preview'
    assert_response :success
  end

  test 'should show comment' do
    login(@reviewer)
    xhr :get, :show, agreement_id: @submitted, id: @reviewer_comment, format: 'js'
    assert_template 'show'
    assert_response :success
  end

  test 'should update comment' do
    login(@reviewer)
    patch :update, agreement_id: @submitted, id: @reviewer_comment, agreement_event: { comment: 'Updated Description' }, format: 'js'
    assert_not_nil assigns(:agreement)
    assert_not_nil assigns(:agreement_event)
    assert_equal 'Updated Description', assigns(:agreement_event).comment
    assert_template 'show'
    assert_response :success
  end

  test 'should not update with blank comment' do
    login(@reviewer)
    patch :update, agreement_id: @submitted, id: @reviewer_comment, agreement_event: { comment: '' }, format: 'js'
    assert_template 'edit'
    assert_response :success
  end

  test 'should not update as another user' do
    login(@reviewer_two)
    patch :update, agreement_id: @submitted, id: @reviewer_comment, agreement_event: { comment: 'Updated Description' }, format: 'js'
    assert_not_nil assigns(:agreement)
    assert_nil assigns(:agreement_event)
    assert_template nil
    assert_response :success
  end

  test 'should destroy comment as admin' do
    login(@admin)
    assert_difference('AgreementEvent.current.count', -1) do
      delete :destroy, agreement_id: @submitted, id: @reviewer_comment, format: 'js'
    end
    assert_not_nil assigns(:agreement)
    assert_template 'destroy'
    assert_response :success
  end

  test 'should destroy comment as comment author' do
    login(@reviewer)
    assert_difference('AgreementEvent.current.count', -1) do
      delete :destroy, agreement_id: @submitted, id: @reviewer_comment, format: 'js'
    end
    assert_not_nil assigns(:agreement)
    assert_template 'destroy'
    assert_response :success
  end

  test 'should not destroy comment as another user' do
    login(@reviewer_two)
    assert_difference('AgreementEvent.current.count', 0) do
      delete :destroy, agreement_id: @agreement, id: @agreement_event, format: 'js'
    end
    assert_template nil
    assert_response :success
  end

  test 'should not destroy comment as anonymous user' do
    assert_difference('AgreementEvent.current.count', 0) do
      delete :destroy, agreement_id: @agreement, id: @agreement_event
    end

    assert_redirected_to new_user_session_path
  end
end
