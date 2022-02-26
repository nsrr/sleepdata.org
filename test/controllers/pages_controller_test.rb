require "test_helper"

# Test that users can view pages.
class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @page = pages(:about)
    @draft = pages(:draft)
    @deleted = pages(:deleted)
  end

  test "should redirect index to root url" do
    get pages_url
    assert_redirected_to root_url
  end

  test "should show page" do
    get page_url(@page)
    assert_response :success
  end

  test "should not show unpublished page" do
    get page_url(@draft)
    assert_redirected_to root_url
  end

  test "should not show deleted page" do
    get page_url(@deleted)
    assert_redirected_to root_url
  end
end
