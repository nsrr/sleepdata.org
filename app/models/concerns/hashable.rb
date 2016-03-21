# frozen_string_literal: true

module Hashable
  extend ActiveSupport::Concern

  included do
    def self.hashids
      Hashids.new(table_name, 6)
    end

    def self.encode_id(id)
      hashids.encode(id)
    end

    def self.decode_id(id)
      hashids.decode(id.to_s).first
    end

    def self.find(hashid)
      super decode_id(hashid) || hashid
    end
  end

  def encoded_id
    self.class.encode_id(id)
  end

  def to_param
    encoded_id
  end
end
