# frozen_string_literal: true

# Generic mailer class defines layout and from email address
class ApplicationMailer < ActionMailer::Base
  default from: "NSRR Sleep Data <#{ActionMailer::Base.smtp_settings[:email]}>"
  helper ApplicationHelper
  helper EmailHelper
  helper MarkdownHelper
  layout "mailer"

  protected

  def setup_email
    # attachments.inline["nsrr-logo.png"] = File.read("app/assets/images/nsrr_logo_64.png") rescue nil
  end
end
