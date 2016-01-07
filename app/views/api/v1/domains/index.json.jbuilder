json.array!(@api_v1_domains) do |api_v1_domain|
  json.extract! api_v1_domain, :id, :name, :create
  json.url api_v1_domain_url(api_v1_domain, format: :json)
end
