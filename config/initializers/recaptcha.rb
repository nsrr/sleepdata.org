# frozen_string_literal: true

RECAPTCHA_ENABLED = \
  if Rails.env.test?
    false
  else
    ENV["recaptcha_enabled"] == "true"
  end
