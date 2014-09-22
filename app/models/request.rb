class Request < ActiveRecord::Base

  belongs_to :agreement
  belongs_to :dataset

end
