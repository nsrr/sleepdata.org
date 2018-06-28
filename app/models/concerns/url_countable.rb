# frozen_string_literal: true

# Provides methods to count the number of URL in text.
module UrlCountable
  extend ActiveSupport::Concern

  def count_urls(text)
    [
      count_uri_urls(text),
      count_pseudo_urls(text)
    ].max
  end

  def count_uri_urls(text)
    URI.extract(text, /http(s)?|mailto|ftp/).count
  end

  def count_pseudo_urls(text)
    return 0 if URL_RULES.blank?
    count = 0
    text.squish.split(/\s/).each do |word|
      count += 1 if word.scan(/#{URL_RULES}/).present?
    end
    count
  end
end
