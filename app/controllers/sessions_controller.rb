# frozen_string_literal: true

# Override for devise sessions controller in order to track a user's location
# when signing out.
class SessionsController < Devise::SessionsController
  layout "full_page"

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
end
