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

  test "should load data dictionary" do
    datasets(:public).load_data_dictionary!
    assert_equal 12, datasets(:public).variables.size
    assert_equal 4, datasets(:public).domains.size
  end
end
