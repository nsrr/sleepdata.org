# frozen_string_literal: true

require "test_helper"

# Tests to assure members can review datasets.
class DatasetReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dataset_review = dataset_reviews(:one)
    @dataset = datasets(:released)
    @regular_user = users(:valid)
    @no_reviews_user = users(:aug)
  end

  def review_params
    { rating: "3", review: "The dataset was OK." }
  end

  test "should get index" do
    get dataset_dataset_reviews_url(@dataset)
    assert_response :success
  end

  test "should get new" do
    login(@no_reviews_user)
    get new_dataset_dataset_review_url(@dataset)
    assert_response :success
  end

  test "should get new and redirect for user with existing review" do
    login(@regular_user)
    get new_dataset_dataset_review_url(@dataset)
    assert_redirected_to edit_dataset_dataset_review_url(@dataset, @dataset_review)
  end

  test "should create review" do
    login(@no_reviews_user)
    assert_difference("DatasetReview.count") do
      post dataset_dataset_reviews_url(@dataset), params: {
        dataset_review: review_params
      }
    end
    assert_redirected_to dataset_dataset_reviews_url(@dataset)
  end

  test "should not create new review for existing review" do
    login(@regular_user)
    assert_difference("DatasetReview.count", 0) do
      post dataset_dataset_reviews_url(@dataset), params: {
        dataset_review: review_params
      }
    end
    assert_redirected_to edit_dataset_dataset_review_url(@dataset, @dataset_review)
  end

  test "should show review" do
    login(@regular_user)
    get dataset_dataset_review_url(@dataset, @dataset_review)
    assert_response :success
  end

  test "should get edit" do
    login(@regular_user)
    get edit_dataset_dataset_review_url(@dataset, @dataset_review)
    assert_response :success
  end

  test "should update review" do
    login(@regular_user)
    patch dataset_dataset_review_url(@dataset, @dataset_review), params: { dataset_review: review_params }
    assert_redirected_to dataset_dataset_reviews_url(@dataset)
  end

  test "should destroy review" do
    login(@regular_user)
    assert_difference("DatasetReview.count", -1) do
      delete dataset_dataset_review_url(@dataset, @dataset_review)
    end
    assert_redirected_to @dataset
  end
end
