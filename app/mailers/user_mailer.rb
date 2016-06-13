# frozen_string_literal: true

# Sends out application emails to users
class UserMailer < ApplicationMailer
  def post_replied(post, user)
    setup_email
    @post = post
    @user = user
    @email_to = user.email
    mail(to: @email_to, subject: "New Forum Reply: #{@post.topic.title}")
  end

  def reviewer_digest(user)
    setup_email
    @user = user
    @email_to = user.email
    mail(to: user.email, subject: "Reviewer Digest for #{Time.zone.today.strftime('%a %d %b %Y')}")
  end

  def daua_submitted(reviewer, agreement)
    setup_email
    @reviewer = reviewer
    @agreement = agreement
    @email_to = reviewer.email
    mail(to: reviewer.email,
         subject: "#{agreement.user.name} #{@agreement.resubmitted? ? 'Resubmitted' : 'Submitted'} a Data Access and Use Agreement")
  end

  def daua_approved(agreement, admin)
    setup_email
    @agreement = agreement
    @email_to = agreement.user.email
    mail(to: agreement.user.email,
         subject: 'Your DAUA Submission has been Approved',
         reply_to: admin.email)
  end

  def daua_signed(agreement)
    setup_email
    @agreement = agreement
    @email_to = agreement.user.email
    mail(to: agreement.user.email,
         subject: 'Your DAUA has been Signed by your Duly Authorized Representative')
  end

  def daua_progress_notification(agreement, admin, agreement_event)
    setup_email
    @agreement = agreement
    @admin = admin
    @email_to = admin.email
    @agreement_event = agreement_event
    mail(to: @email_to,
         subject: "#{@agreement.name}'s DAUA Status Changed to #{@agreement.status.titleize}")
  end

  def sent_back_for_resubmission(agreement, admin)
    setup_email
    @agreement = agreement
    @email_to = agreement.user.email
    mail(to: agreement.user.email,
         subject: 'Please Resubmit your DAUA',
         reply_to: admin.email)
  end

  def mentioned_in_agreement_comment(agreement_event, user)
    setup_email
    @user = user
    @agreement_event = agreement_event
    @email_to = user.email
    mail(to: @email_to,
         subject: "#{agreement_event.user.name} Mentioned You While Reviewing an Agreement")
  end

  def hosting_request_submitted(hosting_request)
    setup_email
    @hosting_request = hosting_request
    @email_to = ENV['support_email']
    mail(to: @email_to,
         subject: "#{hosting_request.user.name} - Dataset Hosting Request")
  end
end
