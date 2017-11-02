# frozen_string_literal: true

require "test_helper"

# Test if agreement event position is calculated correctly.
class AgreementEventTest < ActiveSupport::TestCase
  test "should get agreement event number" do
    assert_equal 0, AgreementEvent.new.number
    assert_equal 1, agreement_events(:submitted_one).number
    assert_equal 2, agreement_events(:submitted_two_comment).number
    assert_equal 3, agreement_events(:submitted_three_tagged).number
  end
end
