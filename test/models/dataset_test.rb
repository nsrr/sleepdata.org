# frozen_string_literal: true

require "test_helper"

# Unit tests for dataset methods.
class DatasetTest < ActiveSupport::TestCase
  test "pending request user is not considered a dataset user" do
    assert_equal false, datasets(:released).viewers.pluck(:id).include?(users(:two).id)
  end

  test "should find dataset by slug" do
    assert_equal datasets(:released), Dataset.find_by_param(datasets(:released).slug)
  end
end
