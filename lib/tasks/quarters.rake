# frozen_string_literal: true

namespace :quarters do
  desc "Populate quarterly downloads."
  task populate: :environment do
    (2013..Time.zone.today.year).each do |year|
      (1..4).each do |quarter_number|
        Quarter.retrieve(year, quarter_number)
      end
    end
  end
end
