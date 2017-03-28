# frozen_string_literal: true

require 'test_helper'

# Tests to assure display of static pages.
class ApplicationControllerTest < ActionController::TestCase
  def google_recaptcha_success
    proc do
      [
        200,
        { 'Content-Type' => 'application/json' },
        [{ success: true, challenge_ts: '', hostname: '' }.to_json]
      ]
    end
  end

  def google_recaptcha_failure
    proc do
      [
        200,
        { 'Content-Type' => 'application/json' },
        [{ success: false, challenge_ts: '', hostname: '' }.to_json]
      ]
    end
  end

  test 'should get verify repacture success' do
    Artifice.activate_with(google_recaptcha_success) do
      assert_equal true, @controller.send(:verify_recaptcha)
    end
  end

  test 'should get verify repacture failure' do
    Artifice.activate_with(google_recaptcha_failure) do
      assert_equal false, @controller.send(:verify_recaptcha)
    end
  end
end
