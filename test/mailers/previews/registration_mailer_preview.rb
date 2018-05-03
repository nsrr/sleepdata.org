# frozen_string_literal: true

# Generates previews for registration and welcome emails.
class RegistrationMailerPreview < ActionMailer::Preview
  def welcome
    user = User.first
    RegistrationMailer.welcome(user)
  end
end
