# frozen_string_literal: true

require 'test_helper'

class ReviewsControllerTest < ActionController::TestCase
  setup do
    @reviewer = users(:reviewer_on_public)
    @agreement = agreements(:submitted_application)
  end

  test 'should get index' do
    login(@reviewer)
    get :index
    assert_response :success
    assert_not_nil assigns(:agreements)
  end

  # Change tags from ['academic', 'publication'] to ['academic', 'student', 'thesis']
  test 'should update agreement tags' do
    login(@reviewer)
    assert_equal [tags(:academic).id, tags(:publication).id].sort, @agreement.tags.pluck(:id).sort
    post :update_tags, params: {
      id: @agreement,
      agreement: {
        tag_ids: [tags(:academic).to_param, tags(:student).to_param, tags(:thesis).to_param]
      }
    }, format: 'js'
    assert_not_nil assigns(:agreement)
    assert_equal [tags(:academic).id, tags(:student).id, tags(:thesis).id].sort, assigns(:agreement).tags.pluck(:id).sort
    assert_not_nil assigns(:agreement_event)
    assert_equal 'tags_updated', assigns(:agreement_event).event_type
    assert_equal @reviewer.id, assigns(:agreement_event).user_id
    assert_equal [tags(:student).id, tags(:thesis).id].sort, assigns(:agreement_event).added_tag_ids.sort
    assert_equal [tags(:publication).id].sort, assigns(:agreement_event).removed_tag_ids.sort
  end

  # test 'should get new' do
  #   get :new
  #   assert_response :success
  # end

  # test 'should create review' do
  #   assert_difference('Review.count') do
  #     post :create, params: { review: { agreement_id: @review.agreement_id, approved: @review.approved, user_id: @review.user_id } }
  #   end

  #   assert_redirected_to review_path(assigns(:review))
  # end

  # test 'should show review' do
  #   get :show, params: { id: @review }
  #   assert_response :success
  # end

  # test 'should get edit' do
  #   get :edit, params: { id: @review }
  #   assert_response :success
  # end

  # test 'should update review' do
  #   patch :update, params: { id: @review, review: { agreement_id: @review.agreement_id, approved: @review.approved, user_id: @review.user_id } }
  #   assert_redirected_to review_path(assigns(:review))
  # end

  # test 'should destroy review' do
  #   assert_difference('Review.count', -1) do
  #     delete :destroy, params: { id: @review }
  #   end

  #   assert_redirected_to reviews_path
  # end
end
