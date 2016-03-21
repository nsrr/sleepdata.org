# frozen_string_literal: true

class AgreementTag < ActiveRecord::Base

  belongs_to :agreement
  belongs_to :tag

end
