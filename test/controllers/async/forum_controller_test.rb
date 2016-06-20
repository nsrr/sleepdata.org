# frozen_string_literal: true

require 'test_helper'

# Tests to assure that users can start new topics from forum index
class Async::ForumControllerTest < ActionController::TestCase
  test 'should get start new topic for public user' do
    post :new_topic, format: 'js'
    assert_template 'new_topic'
    assert_response :success
  end

  test 'should get start new topic for regular user' do
    login(users(:valid))
    post :new_topic, format: 'js'
    assert_template 'new_topic'
    assert_response :success
  end

  test 'should sign in as user' do
    post :login, params: {
      email: 'valid@example.com', password: 'password'
    }, format: 'js'
    assert_template 'create'
    assert_response :success
  end

  test 'should not sign in as user with incorrect password' do
    post :login, params: {
      email: 'valid@example.com', password: 'wrong'
    }, format: 'js'
    assert_template 'new'
    assert_response :success
  end
end
