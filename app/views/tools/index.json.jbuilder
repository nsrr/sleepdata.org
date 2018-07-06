# frozen_string_literal: true

json.array!(@tools) do |tool|
  json.partial! "tools/tool", tool: tool
  json.url tool_url(tool, format: :json)
end
