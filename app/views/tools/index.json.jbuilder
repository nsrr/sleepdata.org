# frozen_string_literal: true

json.array!(@community_tools) do |tool|
  json.partial! "tools/tool", tool: tool
  json.url tool_url(tool, format: :json)
end
