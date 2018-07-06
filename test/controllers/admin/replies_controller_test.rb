# frozen_string_literal: true

require "test_helper"

# Tests to assure that admins can review blog post and forum topic replies.
class Admin::RepliesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
  end

  test "should get index" do
    login(@admin)
    get admin_replies_url
    assert_response :success
  end
end
