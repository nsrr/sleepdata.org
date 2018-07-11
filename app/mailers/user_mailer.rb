# frozen_string_literal: true

# Sends out application emails to users
class UserMailer < ApplicationMailer
  def reviewer_digest(user)
    setup_email
    @user = user
    @email_to = user.email
    mail(to: user.email, subject: "Reviewer Digest for #{Time.zone.today.strftime("%a %d %b %Y")}")
  end

  def daua_submitted(reviewer, agreement)
    setup_email
    @reviewer = reviewer
    @agreement = agreement
    @email_to = reviewer.email
    subject = \
      if @agreement.resubmitted?
        "#{agreement.user.username} Resubmitted a Data Request"
      else
        "#{agreement.user.username} Submitted a Data Request"
      end
    mail(to: reviewer.email, subject: subject)
  end

  def daua_approved(agreement, admin)
    setup_email
    @agreement = agreement
    @email_to = agreement.user.email
    mail(to: agreement.user.email,
         subject: "Your Data Request has been Approved",
         reply_to: admin.email)
  end

  def daua_progress_notification(agreement, admin, agreement_event)
    setup_email
    @agreement = agreement
    @admin = admin
    @email_to = admin.email
    @agreement_event = agreement_event
    mail(to: @email_to,
         subject: "#{@agreement.name}'s Data Request Changed to #{@agreement.status.titleize}")
  end

  def sent_back_for_resubmission(agreement, admin)
    setup_email
    @agreement = agreement
    @email_to = agreement.user.email
    mail(to: agreement.user.email,
         subject: "Please Resubmit your Data Request",
         reply_to: admin.email)
  end

  def mentioned_in_agreement_comment(agreement_event, user)
    setup_email
    @user = user
    @agreement_event = agreement_event
    @email_to = user.email
    mail(to: @email_to,
         subject: "#{agreement_event.user.username} Mentioned You While Reviewing a Data Request")
  end
end
