require 'test_helper'

class DatasetTest < ActiveSupport::TestCase

  test "pending request user is not considered a dataset user" do
    assert_equal false, datasets(:public).viewers.pluck(:id).include?(users(:two).id)
  end

  test "should find dataset by slug" do
    assert_equal datasets(:public), Dataset.find_by_param(datasets(:public).slug)
  end

  test "should remove file indexes" do
    datasets(:public).reset_folder_indexes # Remove and return an array with potential .sleepdata.index files
    assert_equal [], datasets(:public).reset_folder_indexes # Should find no .sleepdata.index files
  end
end
