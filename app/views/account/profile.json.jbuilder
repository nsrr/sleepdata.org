# frozen_string_literal: true

(first_name, last_name) = current_user.full_name.split(" ", 2)

json.authenticated true
json.username current_user.username
json.full_name current_user.full_name
json.first_name first_name
json.last_name last_name
json.email current_user.email
