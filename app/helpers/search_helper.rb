# frozen_string_literal: true

# Helps style simple markdown tags.
module SearchHelper
  def search_style(text)
    text = simple_markdown(text)
    sanitize(text, tags: %w(a strong mark em), attributes: %w(href target))
  end
end
