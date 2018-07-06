# frozen_string_literal: true

require "test_helper"

# Assure that showcase pages display for public users.
class ShowcaseControllerTest < ActionDispatch::IntegrationTest
  setup do
    @regular = users(:regular)
  end

  test "should get showcase for logged out user" do
    get showcase_url
    assert_response :success
  end

  test "should get showcase for regular user" do
    login(@regular)
    get showcase_url
    assert_response :success
  end

  test "should not get non-existent showcase page" do
    get showcase_show_url("nogo")
    assert_redirected_to showcase_url
  end

  test "should get where-to-start for logged out user" do
    get showcase_show_url("where-to-start")
    assert_response :success
  end

  test "should get search-nsrr for logged out user" do
    get showcase_show_url("search-nsrr")
    assert_response :success
  end
end
