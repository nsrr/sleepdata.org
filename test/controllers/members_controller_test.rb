# frozen_string_literal: true

require "test_helper"

# Tests to view member profiles.
class MembersControllerTest < ActionDispatch::IntegrationTest
  test "should get member profile picture with username" do
    get members_profile_picture_url(users(:regular2).username)
    assert_not_nil response
    assert_kind_of String, response.body
    assert_equal File.binread(users(:regular2).profile_picture.thumb.path), response.body
  end

  test "should get member profile picture with id" do
    get members_profile_picture_url(users(:regular2).id)
    assert_not_nil response
    assert_kind_of String, response.body
    assert_equal File.binread(users(:regular2).profile_picture.thumb.path), response.body
  end
end
