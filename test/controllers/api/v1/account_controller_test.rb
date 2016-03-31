# frozen_string_literal: true

require 'test_helper'

# Tests JSON API for account authentication
class Api::V1::AccountControllerTest < ActionController::TestCase
  test 'should get profile as valid user' do
    get :profile, auth_token: users(:valid).id_and_auth_token, format: 'json'
    assert_not_nil response
    profile = JSON.parse(response.body)
    assert_equal true,        profile['authenticated']
    assert_equal 'FirstName', profile['first_name']
    assert_equal 'LastName',  profile['last_name']
    assert_response :success
  end

  test 'should get profile as logged out viewer' do
    get :profile, auth_token: '', format: 'json'
    assert_not_nil response
    profile = JSON.parse(response.body)
    assert_equal false, profile['authenticated']
    assert_equal nil,   profile['first_name']
    assert_equal nil,   profile['last_name']
    assert_response :success
  end
end
