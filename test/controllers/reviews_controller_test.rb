# frozen_string_literal: true

require 'test_helper'

# Tests to assure that submitted agreements can be reviewed and updated.
class ReviewsControllerTest < ActionController::TestCase
  setup do
    @reviewer = users(:reviewer_on_public)
    @reviewer_two = users(:reviewer_two_on_public)
    @reviewer_three = users(:reviewer_three_on_public)
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
    assert_template 'agreement_events/index'
    assert_response :success
  end

  test 'should vote and approve agreement' do
    login(@reviewer)
    assert_difference('Review.count') do
      post :vote, params: { id: @agreement, approved: '1' }, format: 'js'
    end
    assert_equal true, assigns(:review).approved
    assert_equal 'reviewer_approved', assigns(:agreement_event).event_type
    assert_template 'agreement_events/create'
    assert_response :success
  end

  test 'should vote and reject agreement' do
    login(@reviewer)
    assert_difference('Review.count') do
      post :vote, params: { id: @agreement, approved: '0' }, format: 'js'
    end
    assert_equal false, assigns(:review).approved
    assert_equal 'reviewer_rejected', assigns(:agreement_event).event_type
    assert_template 'agreement_events/create'
    assert_response :success
  end

  test 'should not update unchanged vote' do
    login(@reviewer_two)
    assert_difference('Review.count', 0) do
      post :vote, params: { id: @agreement, approved: '0' }, format: 'js'
    end
    assert_equal false, assigns(:review).approved
    assert_nil assigns(:agreement_event)
    assert_template 'agreement_events/create'
    assert_response :success
  end

  test 'should change vote to approved' do
    login(@reviewer_two)
    assert_difference('Review.count', 0) do
      post :vote, params: { id: @agreement, approved: '1' }, format: 'js'
    end
    assert_equal true, assigns(:review).approved
    assert_equal 'reviewer_changed_from_rejected_to_approved', assigns(:agreement_event).event_type
    assert_template 'agreement_events/create'
    assert_response :success
  end

  test 'should change vote to rejected' do
    login(@reviewer_three)
    assert_difference('Review.count', 0) do
      post :vote, params: { id: @agreement, approved: '0' }, format: 'js'
    end
    assert_equal false, assigns(:review).approved
    assert_equal 'reviewer_changed_from_approved_to_rejected', assigns(:agreement_event).event_type
    assert_template 'agreement_events/create'
    assert_response :success
  end
end
