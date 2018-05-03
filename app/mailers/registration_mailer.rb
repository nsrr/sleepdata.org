# frozen_string_literal: true

# Sends out registration welcome emails.
class RegistrationMailer < ApplicationMailer
  def welcome(user, data_request_id: nil)
    setup_email
    @user = user
    @email_to = user.email
    @data_request_id = data_request_id
    mail(to: @email_to, subject: "Welcome to the NSRR!")
  end
end
