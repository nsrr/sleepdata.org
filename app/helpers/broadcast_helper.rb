# frozen_string_literal: true

# Pulls first image tag from description if one exists.
module BroadcastHelper
  def first_image(broadcast)
    match = simple_markdown_new(broadcast.description).match(/<img.*?>/m)
    match[0].to_s.html_safe if match
  end
end
