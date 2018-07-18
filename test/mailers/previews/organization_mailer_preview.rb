# frozen_string_literal: true

# Generates previews for organization invite emails.
class OrganizationMailerPreview < ActionMailer::Preview
  def invitation
    organization_user = OrganizationUser.new(
      organization_id: 1,
      creator_id: 1,
      user_id: 1,
      invite_token: "TOKEN",
      invite_email: "invite@example.com",
      editor: true,
      review_role: "none"
    )
    OrganizationMailer.invitation(organization_user)
  end
end
