# frozen_string_literal: true

source "https://rubygems.org"

gem "rails",                "5.1.4"

# Speed Up Loading Times
gem "bootsnap",             "1.1.5", require: false

# Database Adapter
gem "pg",                   "0.21.0"

# Gems used by project
gem "autoprefixer-rails"
gem "bootstrap",            "~> 4.0.0.beta2"
gem "carrierwave",          "~> 1.2.1"
gem "chunky_png",           "~> 1.3.4"
gem "devise",               "~> 4.3.0"
gem "differ",               "~> 0.1.2"
gem "figaro",               "~> 1.1.1"
gem "font-awesome-rails",   "~> 4.7.0"
gem "haml",                 "~> 5.0.4"
gem "hashids",              "~> 1.0.3"
gem "kaminari",             "~> 1.1.0"
gem "maxminddb",            "~> 0.1.11"
gem "mini_magick",          "~> 4.8.0"
gem "pg_search",            "~> 2.1.0"
gem "redcarpet",            "~> 3.4.0"
gem "sitemap_generator",    "~> 5.3.1"

# Rails Defaults
gem "coffee-rails",         "~> 4.2"
gem "sass-rails",           "~> 5.0"
gem "uglifier",             ">= 1.3.0"

gem "jbuilder",             "~> 2.5"
gem "jquery-rails",         "~> 4.3.1"
gem "turbolinks",           "~> 5"

# Testing
group :test do
  gem "artifice"
  # gem "artifice-passthru"
  gem "minitest"
  gem "puma"
  gem "rails-controller-testing"
  gem "simplecov", "~> 0.15.0", require: false
end

group :development do
  gem "web-console", ">= 3.3.0"
end

group :development, :test do
  gem "capybara", "~> 2.13"
  gem "selenium-webdriver"
end