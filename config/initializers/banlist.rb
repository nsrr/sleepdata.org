# frozen_string_literal: true

# Loads banned emails into memory.
ban_email = Rails.root.join("config", "banemail.yml")
BANNED_EMAILS = (File.exist?(ban_email) ? YAML.load_file(ban_email) : [])

url_regex = Rails.root.join("config", "urlregex.yml")
URL_RULES = (File.exist?(url_regex) ? YAML.load_file(url_regex).collect { |r| "(?:#{r})" }.join("|") : [])
