# frozen_string_literal: true

# Override for devise registrations controller.
class RegistrationsController < Devise::RegistrationsController
  layout "full_page"

  def new
    super
    resource.textcaptcha
  end
end
