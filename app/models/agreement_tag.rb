# frozen_string_literal: true

# Associates an agreement with its corresponding tags
class AgreementTag < ActiveRecord::Base
  belongs_to :agreement
  belongs_to :tag
end
