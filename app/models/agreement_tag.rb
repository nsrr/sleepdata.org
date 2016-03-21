# frozen_string_literal: true

class AgreementTag < ApplicationRecord

  belongs_to :agreement
  belongs_to :tag

end
