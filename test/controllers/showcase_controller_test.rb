# frozen_string_literal: true

require 'test_helper'

class ShowcaseControllerTest < ActionController::TestCase
  test 'should get showcase for logged out user' do
    get :index
    assert_response :success
  end

  test 'should get showcase for regular user' do
    login(@regular_user)
    get :index
    assert_response :success
  end

  test 'should not get non-existent showcase page' do
    get :show, params: { slug: 'nogo' }
    assert_redirected_to showcase_path
  end

  test 'should get where-to-start for logged out user' do
    get :show, params: { slug: 'where-to-start' }
    assert_response :success
  end

  test 'should get search-nsrr for logged out user' do
    get :show, params: { slug: 'search-nsrr' }
    assert_response :success
  end

  test 'should get shaun-purcell-genetics-of-sleep-spindles for logged out user' do
    get :show, params: { slug: 'shaun-purcell-genetics-of-sleep-spindles' }
    assert_response :success
  end
end
