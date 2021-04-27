# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in gems.rb, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SleepData
  # SleepData provides a framework to share research data.
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    # TODO: Remove this line and make :zeitwerk work with module loading dependencies.
    config.autoloader = :classic # :zeitwerk

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rails time:zones" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "Eastern Time (US & Canada)"

    # Ignores custom error DOM elements created by Rails.
    config.action_view.field_error_proc = proc { |html_tag, _instance| html_tag }

    # `form_with` forms are no longer remote by default in Rails 6.1. The
    # following line re-enables the remote form functionality. Upgrading would
    # require all remote forms to specify `local: false`.
    # https://discuss.rubyonrails.org/t/rails-6-1-remote-forms-are-no-longer-default/76912
    config.action_view.form_with_generates_remote_forms = true
  end
end
