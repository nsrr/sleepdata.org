require "test_helper"

# Test that admins can create and edit pages.
class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @page = pages(:about)
    @deleted = pages(:deleted)
  end

  test "should show page" do
    get page_url(@page)
    assert_response :success
  end

  test "should not show deleted page" do
    get page_url(@deleted)
    assert_redirected_to root_url
  end
end
