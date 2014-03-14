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

  def dua_submitted(system_admin, agreement)
    setup_email
    @system_admin = system_admin
    @agreement = agreement
    mail(to: system_admin.email,
         subject: "#{agreement.user.name} Submitted a Data Access and Use Agreement")
  end

  def dua_approved(agreement, admin)
    setup_email
    @agreement = agreement
    mail(to: agreement.user.email,
         subject: "Your DAUA Submission has been Approved",
         reply_to: admin.email)
  end

  def sent_back_for_resubmission(agreement, admin)
    setup_email
    @agreement = agreement
    mail(to: agreement.user.email,
         subject: "Please Resubmit your DAUA",
         reply_to: admin.email)
  end

  protected

  def setup_email
    # @footer_html = "<div style=\"color:#777\">Change #{DEFAULT_APP_NAME} email settings here: <a href=\"#{SITE_URL}/settings\">#{SITE_URL}/settings</a></div><br /><br />".html_safe
    # @footer_txt = "Change #{DEFAULT_APP_NAME} email settings here: #{SITE_URL}/settings"
  end

end
