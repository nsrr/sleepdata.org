# frozen_string_literal: true

require 'test_helper'

# Tests to assure that admins can create and update broadcast categories.
class CategoriesControllerTest < ActionController::TestCase
  setup do
    @category = categories(:one)
    @admin = users(:admin)
  end

  def category_params
    {
      name: 'New Category',
      slug: 'new-slug'
    }
  end

  test 'should get index' do
    login(@admin)
    get :index
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  test 'should get new' do
    login(@admin)
    get :new
    assert_response :success
  end

  test 'should create category' do
    login(@admin)
    assert_difference('Category.count') do
      post :create, category: category_params
    end
    assert_redirected_to category_path(assigns(:category))
  end

  test 'should not create category with blank name' do
    login(@admin)
    assert_difference('Category.count', 0) do
      post :create, category: category_params.merge(name: '')
    end
    assert_template 'new'
    assert_response :success
  end

  test 'should show category' do
    login(@admin)
    get :show, id: @category
    assert_response :success
  end

  test 'should get edit' do
    login(@admin)
    get :edit, id: @category
    assert_response :success
  end

  test 'should update category' do
    login(@admin)
    patch :update, id: @category, category: category_params
    assert_redirected_to category_path(assigns(:category))
  end

  test 'should not update category with blank name' do
    login(@admin)
    patch :update, id: @category, category: category_params.merge(name: '')
    assert_template 'edit'
    assert_response :success
  end

  test 'should destroy category' do
    login(@admin)
    assert_difference('Category.current.count', -1) do
      delete :destroy, id: @category
    end

    assert_redirected_to categories_path
  end
end
