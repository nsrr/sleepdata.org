class AgreementTag < ActiveRecord::Base

  belongs_to :agreement
  belongs_to :tag

end
