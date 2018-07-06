# frozen_string_literal: true

require "test_helper"

# Tests to assure members can review user-submitted tools.
class ToolReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tool_review = tool_reviews(:one)
    @tool = tools(:published)
    @regular_user = users(:valid)
    @no_reviews_user = users(:aug)
  end

  def review_params
    { rating: "3", review: "The tool was OK." }
  end

  test "should get index" do
    get tool_tool_reviews_url(@tool)
    assert_response :success
  end

  test "should get new" do
    login(@no_reviews_user)
    get new_tool_tool_review_url(@tool)
    assert_response :success
  end

  test "should get new and redirect for user with existing review" do
    login(@regular_user)
    get new_tool_tool_review_url(@tool)
    assert_redirected_to edit_tool_tool_review_url(
      @tool, @tool_review
    )
  end

  test "should create review" do
    login(@no_reviews_user)
    assert_difference("ToolReview.count") do
      post tool_tool_reviews_url(@tool), params: {
        tool_review: review_params
      }
    end
    assert_redirected_to tool_tool_reviews_url(
      @tool
    )
  end

  test "should not create new review for existing review" do
    login(@regular_user)
    assert_difference("ToolReview.count", 0) do
      post tool_tool_reviews_url(@tool), params: {
        tool_review: review_params
      }
    end
    assert_redirected_to edit_tool_tool_review_url(
      @tool, @tool_review
    )
  end

  test "should show review" do
    login(@regular_user)
    get tool_tool_review_url(
      @tool, @tool_review
    )
    assert_response :success
  end

  test "should get edit" do
    login(@regular_user)
    get edit_tool_tool_review_url(
      @tool, @tool_review
    )
    assert_response :success
  end

  test "should update review" do
    login(@regular_user)
    patch tool_tool_review_url(
      @tool,
      @tool_review
    ), params: {
      tool_review: review_params
    }
    assert_redirected_to tool_tool_reviews_url(
      @tool
    )
  end

  test "should destroy review" do
    login(@regular_user)
    assert_difference("ToolReview.count", -1) do
      delete tool_tool_review_url(
        @tool, @tool_review
      )
    end
    assert_redirected_to tool_url(@tool)
  end
end
