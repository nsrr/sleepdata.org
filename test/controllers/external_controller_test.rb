# frozen_string_literal: true

require 'test_helper'

SimpleCov.command_name 'test:controllers'

# Tests to assure public pages are displayed correctly.
class ExternalControllerTest < ActionController::TestCase
  test 'should get about' do
    get :about
    assert_response :success
  end

  test 'should get aug' do
    get :aug
    assert_response :success
  end

  test 'should get contact' do
    get :contact
    assert_response :success
  end

  test 'should get contributors' do
    get :contributors
    assert_response :success
  end

  test 'should get landing' do
    get :landing
    assert_response :success
  end

  test 'should get site map' do
    get :sitemap
    assert_response :success
  end

  test 'should get sitemap xml file' do
    get :sitemap_xml
    assert_response :success
  end

  test 'should get team' do
    get :team
    assert_response :success
  end

  test 'should get data sharing language' do
    get :datasharing
    assert_response :success
  end

  test 'should get demo for public user' do
    get :demo
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
    if WwwSleepdataOrg::VERSION::BUILD.nil?
      assert_nil version['version']['build']
    else
      assert_equal WwwSleepdataOrg::VERSION::BUILD, version['version']['build']
    end
    assert_response :success
  end

  test 'should get voting' do
    get :voting
    assert_response :success
  end
end
