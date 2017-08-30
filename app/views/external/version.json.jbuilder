# frozen_string_literal: true

json.version do
  json.string SleepData::VERSION::STRING
  json.major SleepData::VERSION::MAJOR
  json.minor SleepData::VERSION::MINOR
  json.tiny SleepData::VERSION::TINY
  json.build SleepData::VERSION::BUILD
end
