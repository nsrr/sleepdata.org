# frozen_string_literal: true

# rubocop:disable Layout/ExtraSpacing
source "https://rubygems.org"

gem "rails",                      "6.1.4.4"

# PostgreSQL as the Active Record database.
gem "pg",                         "1.5.6"

# Gems used by project.
gem "autoprefixer-rails"
gem "acts_as_textcaptcha",        "~> 4.6.0"
gem "bootstrap",                  "~> 4.4.1"
gem "carrierwave",                "~> 2.2.1"
gem "concurrent-ruby",            "1.3.4"
gem "devise",                     "~> 4.8.0"
gem "differ",                     "~> 0.1.2"
gem "figaro",                     "~> 1.2.0"
gem "font-awesome-sass",          "~> 5.12.0"
gem "haml",                       "~> 5.2.1"
gem "hashids",                    "~> 1.0.5"
gem "kaminari",                   "~> 1.2.1"
gem "mini_magick",                "~> 4.10.1"
gem "net-imap",                   require: false
gem "net-pop",                    require: false
gem "net-smtp",                   require: false
gem "pg_search",                  "~> 2.3.5"
gem "redcarpet",                  "~> 3.5.1"
gem "rubyzip",                    "~> 2.3.0"
gem "sitemap_generator",          "~> 6.0.1"

# Rails defaults.
gem "coffee-rails",               "~> 5.0"
gem "jbuilder",                   "~> 2.9"
gem "jquery-rails",               ">= 4.4.0"
gem "sass-rails",                 ">= 6"
gem "turbolinks",                 "~> 5"
gem "uglifier",                   ">= 1.3.0"

group :development do
  gem "listen",                   "~> 3.3"
  gem "spring"
  gem "spring-watcher-listen",    "~> 2.0.0"
  gem "web-console",              ">= 4.1.0"
end

group :test do
  # gem "artifice"
  # gem "artifice-passthru"
  gem "capybara",                 ">= 3.26"
  gem "minitest"
  gem "puma"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  gem "simplecov",                "~> 0.16.1", require: false
end
# rubocop:enable Layout/ExtraSpacing
