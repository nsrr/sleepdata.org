# frozen_string_literal: true

# Helps generate URLs for user profile pictures.
module ProfilesHelper
  def profile_picture_tag(user, size: 128, style: nil)
    image_tag(
      members_profile_picture_path(user.username.present? ? user.username : user.id),
      alt: "",
      class: "rounded",
      size: "#{size}x#{size}",
      style: style
    )
  end
end
