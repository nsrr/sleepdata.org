# frozen_string_literal: true

# Sends organization invite emails.
class OrganizationMailer < ApplicationMailer
  def invitation(organization_user)
    setup_email
    @organization_user = organization_user
    @creator = organization_user.creator
    @email_to = organization_user.invite_email
    mail(
      to: @email_to,
      subject: "#{@creator.username} invited you to the #{organization_user.organization.name} Organization on the NSRR")
  end
end
