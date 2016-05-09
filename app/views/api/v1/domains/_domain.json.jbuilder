# frozen_string_literal: true

json.extract! domain, :folder, :name, :spout_version

json.options do
  json.array!(domain.domain_options) do |domain_option|
    json.partial! 'api/v1/domain_options/domain_option', domain_option: domain_option
  end
end
