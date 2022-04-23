# frozen_string_literal: true

module SleepData
  module VERSION #:nodoc:
    MAJOR = 57
    MINOR = 2
    TINY = 1
    BUILD = nil # "pre", "beta1", "beta2", "rc", "rc2", nil

    STRING = [MAJOR, MINOR, TINY, BUILD].compact.join(".").freeze
  end
end
