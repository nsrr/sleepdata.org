json.extract! variable, :folder, :name, :display_name, :description, :variable_type, :units, :calculation, :commonly_used, :labels,  :api_version

json.domain do
  json.partial! 'api/v1/domains/domain', domain: variable.domain if variable.domain
end

json.forms do
  json.array!(variable.forms) do |form|
    json.partial! 'api/v1/forms/form', form: form
  end
end
