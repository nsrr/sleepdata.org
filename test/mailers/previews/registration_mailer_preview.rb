# frozen_string_literal: true

# Generates previews for registration and welcome emails.
class RegistrationMailerPreview < ActionMailer::Preview
  def welcome
    user = User.first
    RegistrationMailer.welcome(user)
  end

  def welcome_with_data_request
    user = User.last
    data_request = user.data_requests.last
    RegistrationMailer.welcome(user, data_request_id: data_request&.id)
  end
end
