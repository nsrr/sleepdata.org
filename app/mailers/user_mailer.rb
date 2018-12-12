# frozen_string_literal: true

# Sends out application emails to users
class UserMailer < ApplicationMailer
  def reviewer_digest(user)
    setup_email
    @user = user
    @email_to = user.email
    mail(to: user.email, subject: "Reviewer digest for #{Time.zone.today.strftime("%a %d %b %Y")}")
  end

  def daua_submitted(reviewer, agreement)
    setup_email
    @reviewer = reviewer
    @agreement = agreement
    @email_to = reviewer.email
    subject = "#{@agreement.complex_name_or_username} #{@agreement.resubmitted? ? "resubmitted" : "submitted"} a data request"
    mail(to: reviewer.email, subject: subject)
  end

  def daua_approved(agreement, admin)
    setup_email
    @agreement = agreement
    @email_to = agreement.user.email
    mail(to: agreement.user.email,
         subject: "Your data request has been approved",
         reply_to: admin.email)
  end

  def daua_progress_notification(agreement, admin, agreement_event)
    setup_email
    @agreement = agreement
    @admin = admin
    @email_to = admin.email
    @agreement_event = agreement_event
    mail(to: @email_to,
         subject: "#{@agreement.complex_name_or_username}'s data request changed to #{@agreement.status}")
  end

  def sent_back_for_resubmission(agreement, admin)
    setup_email
    @agreement = agreement
    @email_to = agreement.user.email
    mail(to: agreement.user.email,
         subject: "Please resubmit your data request",
         reply_to: admin.email)
  end

  def mentioned_in_agreement_comment(agreement_event, user)
    setup_email
    @user = user
    @agreement_event = agreement_event
    @email_to = user.email
    mail(to: @email_to,
         subject: "#{agreement_event.user.username} mentioned you on a data request")
  end
end
