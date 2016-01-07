json.array!(@variables) do |variable|
  json.partial! 'api/v1/variables/variable', variable: variable
  # json.path variable_path(variable, format: :json)
end
