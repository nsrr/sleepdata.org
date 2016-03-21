# frozen_string_literal: true

class PublicFile < ApplicationRecord

  belongs_to :dataset
  belongs_to :user

end
