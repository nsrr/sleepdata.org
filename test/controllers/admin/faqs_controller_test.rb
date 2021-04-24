require "test_helper"

# Test that admins can create and edit about page FAQs.
class FaqsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @faq = faqs(:one)
    @admin = users(:admin)
  end

  def faq_params
    {
      question: "How do I write a question?",
      answer: "You provide an answer.",
      display: "1",
      position: "1"
    }
  end

  test "should get index" do
    login(@admin)
    get admin_faqs_url
    assert_response :success
  end

  test "should get new" do
    login(@admin)
    get new_admin_faq_url
    assert_response :success
  end

  test "should create faq" do
    login(@admin)
    assert_difference('Faq.count') do
      post admin_faqs_url, params: { faq: faq_params }
    end

    assert_redirected_to admin_faq_url(Faq.last)
  end

  test "should show faq" do
    login(@admin)
    get admin_faq_url(@faq)
    assert_response :success
  end

  test "should get edit" do
    login(@admin)
    get edit_admin_faq_url(@faq)
    assert_response :success
  end

  test "should update faq" do
    login(@admin)
    patch admin_faq_url(@faq), params: { faq: faq_params }
    assert_redirected_to admin_faq_url(@faq)
  end

  test "should destroy faq" do
    login(@admin)
    assert_difference("Faq.current.count", -1) do
      delete admin_faq_url(@faq)
    end

    assert_redirected_to admin_faqs_url
  end
end
