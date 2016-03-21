# frozen_string_literal: true

require 'test_helper'

class ReviewsControllerTest < ActionController::TestCase
  setup do
    @review = reviews(:one)
  end

  test 'should get index' do
    login(users(:editor))
    get :index
    assert_response :success
    assert_not_nil assigns(:agreements)
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
