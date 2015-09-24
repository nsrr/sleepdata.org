require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  setup do
    @regular_user = users(:valid)
  end

  test 'should get demo for logged out user' do
    get :demo
    assert_response :success
  end

  test 'should get demo for regular user' do
    login(@regular_user)
    get :demo
    assert_response :success
  end

  test 'should get parallax' do
    get :parallax
    assert_response :success
  end

  test 'should get parallax2' do
    get :parallax2
    assert_response :success
  end

  test 'should get map' do
    get :map
    assert_response :success
  end

  test 'should get version' do
    get :version
    assert_response :success
  end

  test 'should get version as json' do
    get :version, format: 'json'
    version = JSON.parse(response.body)
    assert_equal WwwSleepdataOrg::VERSION::STRING, version['version']['string']
    assert_equal WwwSleepdataOrg::VERSION::MAJOR, version['version']['major']
    assert_equal WwwSleepdataOrg::VERSION::MINOR, version['version']['minor']
    assert_equal WwwSleepdataOrg::VERSION::TINY, version['version']['tiny']
    assert_equal WwwSleepdataOrg::VERSION::BUILD, version['version']['build']
    assert_response :success
  end
end
