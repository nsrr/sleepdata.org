# Generates previews for registration and welcome emails.
class RegistrationMailerPreview < ActionMailer::Preview
  def send_welcome_email_with_password
    user = User.first
    RegistrationMailer.send_welcome_email_with_password(user, SecureRandom.hex(8))
  end
end
