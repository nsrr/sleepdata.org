# frozen_string_literal: true

require 'test_helper'

# Test to make sure blog is publicly accessible
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
    get :show, slug: broadcasts(:published).slug
    assert_response :success
  end

  test 'should not show draft blog' do
    get :show, slug: broadcasts(:draft).slug
    assert_redirected_to blog_path
  end
end
