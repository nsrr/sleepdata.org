class PublicFile < ApplicationRecord

  belongs_to :dataset
  belongs_to :user

end
