require "test_helper"

# Test that admins can create and edit pages.
class Admin::PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @page = pages(:about)
    @admin = users(:admin)
  end

  def page_params
    {
      title: "Home",
      slug: "home",
      description: "Home page."
    }
  end

  test "should get index" do
    login(@admin)
    get admin_pages_url
    assert_response :success
  end

  test "should get new" do
    login(@admin)
    get new_admin_page_url
    assert_response :success
  end

  test "should create page" do
    login(@admin)
    assert_difference("Page.count") do
      post admin_pages_url, params: { page: page_params }
    end

    assert_redirected_to admin_page_url(Page.last)
  end

  test "should show page" do
    login(@admin)
    get admin_page_url(@page)
    assert_response :success
  end

  test "should get edit" do
    login(@admin)
    get edit_admin_page_url(@page)
    assert_response :success
  end

  test "should update page" do
    login(@admin)
    patch admin_page_url(@page), params: { page: page_params }
    @page.reload
    assert_redirected_to admin_page_url(@page)
  end

  test "should destroy page" do
    login(@admin)
    assert_difference("Page.current.count", -1) do
      delete admin_page_url(@page)
    end

    assert_redirected_to admin_pages_url
  end
end
