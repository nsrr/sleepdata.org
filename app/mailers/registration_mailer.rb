# Sends out registration welcome emails
class RegistrationMailer < ApplicationMailer
  def send_welcome_email_with_password(user, pw)
    setup_email
    @user = user
    @pw = pw
    @email_to = user.email
    mail(to: @email_to,
         subject: 'Welcome to the NSRR - Account Created')
  end
end
