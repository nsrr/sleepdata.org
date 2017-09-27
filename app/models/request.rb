# frozen_string_literal: true

class Request < ApplicationRecord
  belongs_to :agreement
  belongs_to :dataset
end
