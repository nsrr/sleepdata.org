json.array!(@domains) do |domain|
  json.partial! 'api/v1/domains/domain', domain: domain
  # json.path domain_path(domain, format: :json)
end
