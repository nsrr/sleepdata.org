# frozen_string_literal: true

# Sends out application emails to users
class UserMailer < ApplicationMailer
  def reviewer_digest(user)
    setup_email
    @user = user
    @email_to = user.email
    mail(to: user.email, subject: "Reviewer digest for #{Time.zone.today.strftime("%a %d %b %Y")}")
  end

  def daua_approved(agreement, admin)
    setup_email
    @agreement = agreement
    @email_to = agreement.user.email
    mail(to: agreement.user.email,
         subject: "Your data request has been approved",
         reply_to: admin.email)
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
