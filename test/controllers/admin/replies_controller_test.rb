# frozen_string_literal: true

require 'test_helper'

# Tests to assure that admins can review blog post and forum topic replies.
class Admin::RepliesControllerTest < ActionController::TestCase
  test 'should get index' do
    login(users(:admin))
    get :index
    assert_response :success
  end
end
