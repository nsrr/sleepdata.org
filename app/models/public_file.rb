# frozen_string_literal: true

class PublicFile < ActiveRecord::Base

  belongs_to :dataset
  belongs_to :user

end
