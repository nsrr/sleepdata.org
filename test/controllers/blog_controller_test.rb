# frozen_string_literal: true

require 'test_helper'

class BlogControllerTest < ActionController::TestCase
  test 'should get blog' do
    get :blog
    assert_response :success
  end

  test 'should get blog atom feed' do
    get :blog, format: 'atom'
    assert_response :success
  end

  test 'should show published blog' do
    get :show, id: broadcasts(:published)
    assert_response :success
  end

  test 'should not show draft blog' do
    get :show, id: broadcasts(:draft)
    assert_redirected_to blog_path
  end
end
