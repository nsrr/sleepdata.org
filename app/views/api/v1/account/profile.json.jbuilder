# frozen_string_literal: true

if current_user
  json.authenticated true
  json.first_name current_user.first_name
  json.last_name current_user.last_name
  json.email current_user.email
else
  json.authenticated false
end
