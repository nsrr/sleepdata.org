# frozen_string_literal: true

# Caches quarterly downloads for dataset file audits.
class Quarter < ApplicationRecord
  def self.retrieve(year, quarter_number)
    quarter = find_by(year: year, quarter_number: quarter_number)
    return quarter if quarter
    quarter = new(year: year, quarter_number: quarter_number)
    return quarter if quarter.future?
    quarter.recompute!
    quarter.save unless quarter.current?
    quarter
  end

  def start_date
    Date.parse("#{year}-#{quarter_number * 3}-01") + 7.months
  end

  def end_date
    (Date.parse("#{year}-#{quarter_number * 3}-01") + 9.months).end_of_month
  end

  def future?
    start_date > Time.zone.today
  end

  def current?
    end_date >= Time.zone.today
  end

  def dfa_regular
    DatasetFileAudit.regular_members
  end

  def recompute!
    recompute_regular_files!
    recompute_regular_total_files!
  end

  def recompute_regular_files!
    scope = dfa_regular.where(created_at: start_date..end_date)
    self.regular_files = scope.count
    self.regular_file_size = scope.sum(:file_size)
  end

  def recompute_regular_total_files!
    scope = dfa_regular.where("DATE(dataset_file_audits.created_at) <= ?", end_date)
    self.regular_total_files = scope.count
    self.regular_total_file_size = scope.sum(:file_size)
  end
end
