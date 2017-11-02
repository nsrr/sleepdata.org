# frozen_string_literal: true

require "test_helper"

# Tests emails related to the data request process.
class DataRequestMailerTest < ActionMailer::TestCase
  setup do
    @data_request = data_requests(:duly_authorized_signature_requested)
  end

  test "duly authorized representative signature request" do
    mail = DataRequestMailer.duly_authorized_representative_signature_request(@data_request)
    assert_equal "Designated as the Duly Authorized Representative on a Data Request", mail.subject
    assert_equal [@data_request.duly_authorized_representative_email], mail.to
    assert_equal [@data_request.user.email], mail.cc
    assert_match(
      "You have been designated as #{@data_request.user.name}'s Duly\r\nAuthorized Representative\.",
      mail.body.encoded
    )
  end

  test "duly authorized representative signature submitted" do
    mail = DataRequestMailer.duly_authorized_representative_signature_submitted(@data_request)
    assert_equal "Your Duly Authorized Representative Has Signed Your Data Request", mail.subject
    assert_equal [@data_request.user.email], mail.to
    assert_match(
      /Your Data Request has been signed by \
#{@data_request.duly_authorized_representative_signature_print}, your Duly Authorized Representative\./,
      mail.body.encoded
    )
  end
end
