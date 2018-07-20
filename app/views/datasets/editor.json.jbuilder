# frozen_string_literal: true

json.editor @dataset.editor?(current_user)
json.user_id current_user&.id
