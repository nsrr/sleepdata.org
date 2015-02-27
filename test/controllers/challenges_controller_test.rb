require 'test_helper'

class ChallengesControllerTest < ActionController::TestCase
  setup do
    @challenge = challenges(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:challenges)
  end

  test "should get new" do
    login(users(:admin))
    get :new
    assert_response :success
  end

  test "should create challenge" do
    login(users(:admin))
    assert_difference('Challenge.count') do
      post :create, challenge: { name: 'New Challenge', slug: 'new-challenge', description: @challenge.description, public: '1' }
    end

    assert_redirected_to challenge_path(assigns(:challenge))
  end

  test "should show challenge" do
    get :show, id: @challenge
    assert_response :success
  end

  test "should get edit" do
    login(users(:admin))
    get :edit, id: @challenge
    assert_response :success
  end

  test "should update challenge" do
    login(users(:admin))
    patch :update, id: @challenge, challenge: { name: 'Update Challenge', slug: 'update-challenge', description: @challenge.description, public: '1' }
    assert_redirected_to challenge_path(assigns(:challenge))
  end

  test "should destroy challenge" do
    login(users(:admin))
    assert_difference('Challenge.current.count', -1) do
      delete :destroy, id: @challenge
    end

    assert_redirected_to challenges_path
  end
end
