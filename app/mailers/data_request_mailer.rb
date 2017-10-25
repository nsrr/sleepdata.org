# frozen_string_literal: true

# Sends emails related to the data request process.
class DataRequestMailer < ApplicationMailer
  def duly_authorized_representative_signature_request(data_request)
    setup_email
    @data_request = data_request
    @email_to = @data_request.duly_authorized_representative_email

    mail(
      to: @email_to,
      cc: @data_request.user.email,
      subject: "Designated as the Duly Authorized Representative on a Data Request"
    )
  end

  def duly_authorized_representative_signature_submitted(data_request)
    setup_email
    @data_request = data_request
    @email_to = data_request.user.email
    mail(
      to: @email_to,
      subject: "Your Duly Authorized Representative Has Signed Your Data Request"
    )
  end
end
