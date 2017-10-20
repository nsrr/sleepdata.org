# frozen_string_literal: true

# Adds a recaptcha on registration.
class RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: [:create]
  layout "full_page"

  private

  def check_captcha
    return unless RECAPTCHA_ENABLED && !verify_recaptcha
    self.resource = resource_class.new sign_up_params
    resource.errors.add(:recaptcha, "reCAPTCHA verification failed.")
    respond_with_navigational(resource) { render :new }
  end
end
