# frozen_string_literal: true

require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  setup do
    @tag = tags(:meeting)
    @admin = login(users(:admin))
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:tags)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create tag' do
    assert_difference('Tag.count') do
      post :create, params: { tag: { name: 'Blog', color: @tag.color, tag_type: 'topic' } }
    end

    assert_redirected_to tag_path(assigns(:tag))
  end

  test 'should not create tag with non-unique name' do
    assert_difference('Tag.count', 0) do
      post :create, params: { tag: { name: 'Meeting', color: @tag.color, tag_type: 'topic' } }
    end

    assert_not_nil assigns(:tag)
    assert assigns(:tag).errors.size > 0
    assert_equal ['has already been taken'], assigns(:tag).errors[:name]

    assert_template 'new'
  end

  test 'should show tag' do
    get :show, params: { id: @tag }
    assert_response :success
  end

  test 'should get edit' do
    get :edit, params: { id: @tag }
    assert_response :success
  end

  test 'should update tag' do
    patch :update, params: { id: @tag, tag: { name: 'Meetings', color: @tag.color, tag_type: 'topic' } }
    assert_redirected_to tag_path(assigns(:tag))
  end

  test 'should not update tag with blank name' do
    patch :update, params: { id: @tag, tag: { name: '', color: @tag.color, tag_type: 'topic' } }

    assert_not_nil assigns(:tag)
    assert assigns(:tag).errors.size > 0
    assert_equal ["can't be blank"], assigns(:tag).errors[:name]

    assert_template 'edit'
  end

  test 'should destroy tag' do
    assert_difference('Tag.current.count', -1) do
      delete :destroy, params: { id: @tag }
    end

    assert_redirected_to tags_path
  end
end
