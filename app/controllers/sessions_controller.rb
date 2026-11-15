# frozen_string_literal: true

# Override for devise sessions controller in order to track a user's location
# when signing out.
class SessionsController < Devise::SessionsController
  layout "full_page"

  # The attestation must be checked before Devise attempts to authenticate the
  # submitted credentials, otherwise rendering the form again could still sign
  # the user in (warden authenticates from params when `current_user` is read).
  prepend_before_action :require_attestation, only: :create

  # The time of the most recent attestation is stored on the user after a
  # successful login.
  # POST /login
  def create
    super do |resource|
      resource.save_attestation! if resource.persisted?
    end
  end

  # The Devise sign_out method deletes the entire session. We need the session
  # :previous_url in order to friendly redirect back to the page the user was
  # on when they were signing out.
  # DELETE /resource/sign_out
  def destroy
    previous_url = session[:previous_external_url] # Temporarily store previous_url
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    session[:previous_external_url] = previous_url # Restore previous_url to session
    set_flash_message :notice, :signed_out if signed_out && is_flashing_format?
    yield if block_given?
    respond_to_on_destroy
  end

  private

  def require_attestation
    return if params.dig(:user, :not_covered_person_or_located_in_country_of_concern_attestation) == "1"
    self.resource = resource_class.new(sign_in_params.except(:password))
    resource.errors.add(:not_covered_person_or_located_in_country_of_concern_attestation, User::ATTESTATION_ERROR_MESSAGE)
    render :new
  end
end
