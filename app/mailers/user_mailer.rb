class UserMailer < ActionMailer::Base
  default from: "#{DEFAULT_APP_NAME} <#{ActionMailer::Base.smtp_settings[:email]}>"
  add_template_helper(ApplicationHelper)

  def notify_system_admin(system_admin, user)
    setup_email
    @system_admin = system_admin
    @user = user
    mail(to: system_admin.email,
         subject: "#{user.name} Signed Up",
         reply_to: user.email)
  end

  protected

  def setup_email
    # @footer_html = "<div style=\"color:#777\">Change #{DEFAULT_APP_NAME} email settings here: <a href=\"#{SITE_URL}/settings\">#{SITE_URL}/settings</a></div><br /><br />".html_safe
    # @footer_txt = "Change #{DEFAULT_APP_NAME} email settings here: #{SITE_URL}/settings"
  end

end
