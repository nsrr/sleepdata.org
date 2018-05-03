# frozen_string_literal: true

require "test_helper"

SimpleCov.command_name "test:models"

# Unit tests for users.
class UserTest < ActiveSupport::TestCase
  test "should get initials" do
    assert_equal "RU", users(:regular).initials
  end
end
