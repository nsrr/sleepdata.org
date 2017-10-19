# frozen_string_literal: true

require "test_helper"

# Test if agreement event position is calculated correctly.
class AgreementEventTest < ActiveSupport::TestCase
  test 'should get agreement event number' do
    assert_equal 0, AgreementEvent.new.number
    assert_equal 1, agreement_events(:one_submitted).number
  end
end
