require 'test_helper'

class DatasetTest < ActiveSupport::TestCase

  test "pending request user is not considered a dataset user" do
    assert_equal false, datasets(:public).viewers.pluck(:id).include?(users(:two).id)
  end

  test "should find dataset by slug" do
    assert_equal datasets(:public), Dataset.find_by_param(datasets(:public).slug)
  end
end
