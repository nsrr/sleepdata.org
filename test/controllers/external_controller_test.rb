require 'test_helper'

# Test for publicly available pages
class ExternalControllerTest < ActionController::TestCase
  test 'should get about' do
    get :about
    assert_response :success
  end

  # test 'should get contact' do
  #   get :contact
  #   assert_response :success
  # end

  test 'should get landing' do
    get :landing
    assert_response :success
  end

  test 'should get site map' do
    get :sitemap
    assert_response :success
  end
end
