# frozen_string_literal: true

# Verify recaptcha.
class RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: [:create]

  private

  def check_captcha
    if RECAPTCHA_ENABLED && !verify_recaptcha
      self.resource = resource_class.new sign_up_params
      respond_with_navigational(resource) { render :new }
    end
  end

  def verify_recaptcha
    url = URI.parse('https://www.google.com/recaptcha/api/siteverify')
    http = Net::HTTP.new(url.host, url.port)
    if url.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    post_params = [
      "secret=#{ENV['recaptcha_secret_key']}",
      "response=#{params['g-recaptcha-response']}",
      "remoteip=#{request.remote_ip}"
    ]
    response = http.start do |h|
      h.post(url.path, post_params.join('&'))
    end
    json = JSON.parse(response.body)
    json['success']
  end
end
