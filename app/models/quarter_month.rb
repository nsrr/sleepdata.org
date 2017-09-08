# frozen_string_literal: true

# Caches monthly downloads for dataset file audits.
class QuarterMonth < ApplicationRecord
  # Relationships
  belongs_to :quarter, optional: true

  # Methods
  def self.retrieve(year, month_number)
    month = find_by(year: year, month_number: month_number)
    return month if month
    month = new(year: year, month_number: month_number)
    return month if month.future?
    month.recompute!
    month.save unless month.current?
    month
  end

  def start_date
    Date.parse("#{year}-#{month_number}-01")
  end

  def end_date
    start_date.end_of_month
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
    recompute_regular_total_files! unless current?
  end

  def recompute_regular_files!
    scope = dfa_regular.where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    self.regular_files = scope.count
    self.regular_file_size = scope.sum(:file_size)
  end

  def recompute_regular_total_files!
    scope = dfa_regular.where("dataset_file_audits.created_at <= ?", end_date.end_of_day)
    self.regular_total_files = scope.count
    self.regular_total_file_size = scope.sum(:file_size)
  end
end
