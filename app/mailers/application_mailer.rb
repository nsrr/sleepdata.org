class ApplicationMailer < ActionMailer::Base
  default from: "NSRR Sleep Data <#{ActionMailer::Base.smtp_settings[:email]}>"
  add_template_helper(ApplicationHelper)
  layout 'mailer'

  protected

  def setup_email
    # attachments.inline['nsrr-logo.png'] = File.read('app/assets/images/nsrr_logo_64.png') rescue nil
  end
end
