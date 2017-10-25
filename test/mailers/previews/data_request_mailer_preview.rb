# frozen_string_literal: true

# Preview data request process emails.
class DataRequestMailerPreview < ActionMailer::Preview
  def duly_authorized_representative_signature_request
    DataRequestMailer.duly_authorized_representative_signature_request(data_request)
  end

  def duly_authorized_representative_signature_submitted
    DataRequestMailer.duly_authorized_representative_signature_submitted(data_request)
  end

  private

  def data_request
    dr = DataRequest.new(
      user: User.first,
      status: "started", duly_authorized_representative_signature_print: "Legal Department",
      duly_authorized_representative_token: SecureRandom.hex(12)
    )
    dr
  end
end
