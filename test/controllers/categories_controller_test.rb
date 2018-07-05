# frozen_string_literal: true

require "test_helper"

# Tests to assure that admins can create and update broadcast categories.
class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = categories(:one)
    @admin = users(:admin)
  end

  def category_params
    {
      name: "New Category",
      slug: "new-slug"
    }
  end

  test "should get index" do
    login(@admin)
    get categories_url
    assert_response :success
  end

  test "should get new" do
    login(@admin)
    get new_category_url
    assert_response :success
  end

  test "should create category" do
    login(@admin)
    assert_difference("Category.count") do
      post categories_url, params: { category: category_params }
    end
    assert_redirected_to category_url(assigns(:category))
  end

  test "should not create category with blank name" do
    login(@admin)
    assert_difference("Category.count", 0) do
      post categories_url, params: { category: category_params.merge(name: "") }
    end
    assert_template "new"
    assert_response :success
  end

  test "should show category" do
    login(@admin)
    get category_url(@category)
    assert_response :success
  end

  test "should get edit" do
    login(@admin)
    get edit_category_url(@category)
    assert_response :success
  end

  test "should update category" do
    login(@admin)
    patch category_url(@category), params: { category: category_params }
    assert_redirected_to category_url(assigns(:category))
  end

  test "should not update category with blank name" do
    login(@admin)
    patch category_url(@category), params: {
      category: category_params.merge(name: "")
    }
    assert_template "edit"
    assert_response :success
  end

  test "should destroy category" do
    login(@admin)
    assert_difference("Category.current.count", -1) do
      delete category_url(@category)
    end
    assert_redirected_to categories_url
  end
end
