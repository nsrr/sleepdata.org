require 'test_helper'

class CommunityToolReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @community_tool_review = community_tool_reviews(:one)
    @community_tool = community_tools(:published)
    @regular_user = users(:valid)
    @no_reviews_user = users(:aug)
  end

  def review_params
    { rating: '3', review: 'The tool was OK.' }
  end

  test 'should get index' do
    get community_tool_community_tool_reviews_path(@community_tool)
    assert_response :success
  end

  test 'should get new' do
    login(@no_reviews_user)
    get new_community_tool_community_tool_review_path(@community_tool)
    assert_response :success
  end

  test 'should get new and redirect for user with existing review' do
    login(@regular_user)
    get new_community_tool_community_tool_review_path(@community_tool)
    assert_redirected_to edit_community_tool_community_tool_review_path(@community_tool, @community_tool_review)
  end

  test 'should create review' do
    login(@no_reviews_user)
    assert_difference('CommunityToolReview.count') do
      post community_tool_community_tool_reviews_path(@community_tool), params: {
        community_tool_review: review_params
      }
    end
    assert_redirected_to community_show_tool_path(@community_tool)
  end

  test 'should not create new review for existing review' do
    login(@regular_user)
    assert_difference('CommunityToolReview.count', 0) do
      post community_tool_community_tool_reviews_path(@community_tool), params: {
        community_tool_review: review_params
      }
    end
    assert_redirected_to edit_community_tool_community_tool_review_path(@community_tool, @community_tool_review)
  end

  test 'should show review' do
    login(@regular_user)
    get community_tool_community_tool_review_path(@community_tool, @community_tool_review)
    assert_response :success
  end

  test 'should get edit' do
    login(@regular_user)
    get edit_community_tool_community_tool_review_path(@community_tool, @community_tool_review)
    assert_response :success
  end

  test 'should update review' do
    login(@regular_user)
    patch community_tool_community_tool_review_path(@community_tool, @community_tool_review), params: { community_tool_review: review_params }
    assert_redirected_to community_show_tool_path(@community_tool)
  end

  test 'should destroy review' do
    login(@regular_user)
    assert_difference('CommunityToolReview.count', -1) do
      delete community_tool_community_tool_review_path(@community_tool, @community_tool_review)
    end
    assert_redirected_to community_show_tool_path(@community_tool)
  end
end
