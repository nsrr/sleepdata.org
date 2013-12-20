require 'test_helper'

class VariableTest < ActiveSupport::TestCase
  test "should get variable score" do
    assert_equal 2, variables(:one).score(['gender'])
    assert_equal 2.5, variables(:one).score(['gen', 'demographics', 'other'])
    assert_equal 1.5, variables(:one).score(['gen', 'other'])
    assert_equal 0.5, variables(:one).score(['other'])
    assert_equal 0.5, variables(:one).score([])

    assert_equal 1, variables(:two).score(['two', 'other'])
    assert_equal 1, variables(:two).score(['two'])
    assert_equal 0, variables(:two).score(['other'])
    assert_equal 0, variables(:two).score([])
  end
end
