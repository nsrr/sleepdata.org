class UserMailer < ActionMailer::Base
  default from: "#{DEFAULT_APP_NAME} <#{ActionMailer::Base.smtp_settings[:email]}>"
  add_template_helper(ApplicationHelper)

  def forum_digest(user)
    setup_email
    @user = user
    @email_to = user.email
    mail(to: user.email, subject: "Forum Digest for #{Date.today.strftime('%a %d %b %Y')}")
  end

  def notify_system_admin(system_admin, user)
    setup_email
    @system_admin = system_admin
    @user = user
    @email_to = system_admin.email
    mail(to: system_admin.email,
         subject: "#{user.name} Signed Up",
         reply_to: user.email)
  end

  def daua_submitted(system_admin, agreement)
    setup_email
    @system_admin = system_admin
    @agreement = agreement
    @email_to = system_admin.email
    mail(to: system_admin.email,
         subject: "#{agreement.user.name} Submitted a Data Access and Use Agreement")
  end

  def daua_approved(agreement, admin)
    setup_email
    @agreement = agreement
    @email_to = agreement.user.email
    mail(to: agreement.user.email,
         subject: "Your DAUA Submission has been Approved",
         reply_to: admin.email)
  end

  def daua_progress_notification(agreement, admin)
    setup_email
    @agreement = agreement
    @admin = admin
    @email_to = admin.email
    @last_event = @agreement.history.last
    @last_user = User.find_by_id(@last_event[:user_id])

    mail(to: @email_to,
         subject: "#{@agreement.name}'s DAUA Status Changed to #{@agreement.status.titleize}")
  end

  def sent_back_for_resubmission(agreement, admin)
    setup_email
    @agreement = agreement
    @email_to = agreement.user.email
    mail(to: agreement.user.email,
         subject: "Please Resubmit your DAUA",
         reply_to: admin.email)
  end

  def dataset_access_requested(dataset_user, editor)
    setup_email
    @dataset_user = dataset_user
    @editor = editor
    @email_to = editor.email
    mail(to: @email_to,
         subject: "#{dataset_user.user.name} Requested Dataset File Access on #{dataset_user.dataset.name}")
  end

  def dataset_access_approved(dataset_user, editor)
    setup_email
    @dataset_user = dataset_user
    @editor = editor
    @email_to = dataset_user.user.email
    mail(to: @email_to,
         subject: "Your #{dataset_user.dataset.name} File Access Request Has Been Approved By #{@editor.name}",
         reply_to: editor.email)
  end

  protected

  def setup_email
    attachments.inline['nsrr-logo.png'] = File.read('app/assets/images/nsrr_logo_64.png')
  end

end
