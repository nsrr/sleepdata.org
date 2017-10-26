# frozen_string_literal: true

# Caches quarterly downloads for dataset file audits.
class Quarter < ApplicationRecord
  # Relationships
  has_many :quarter_months

  # Methods
  def self.retrieve(year, quarter_number)
    quarter = find_by(year: year, quarter_number: quarter_number)
    quarter = new(year: year, quarter_number: quarter_number) unless quarter
    return quarter if quarter.future?
    quarter.save
    quarter.compute_months!
    quarter
  end

  # The use of collect is intentional to also account for unsaved current
  # QuarterMonths, as opposed to pluck which would only sum records saved in the
  # database.
  def regular_files
    quarter_months.collect(&:regular_files).sum.to_i
  end

  def regular_file_size
    quarter_months.collect(&:regular_file_size).sum.to_i
  end

  def regular_total_files
    quarter_months.collect(&:regular_total_files).max.to_i
  end

  def regular_total_file_size
    quarter_months.collect(&:regular_total_file_size).max.to_i
  end

  def regular_total_files_with_temp
    last_month = QuarterMonth.order(regular_total_file_size: :desc).first
    (last_month&.regular_total_files || 0) + quarter_months.select(&:current?).collect(&:regular_files).sum.to_i
  end

  def regular_total_file_size_with_temp
    last_month = QuarterMonth.order(regular_total_file_size: :desc).first
    (last_month&.regular_total_file_size || 0) + quarter_months.select(&:current?).collect(&:regular_file_size).sum.to_i
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

  def compute_months!
    (0..2).each do |shift|
      month_number = (start_date + shift.month).month
      month_year = (start_date + shift.month).year
      month = quarter_months.find_by(year: month_year, month_number: month_number)
      next if month
      month = quarter_months.new(year: month_year, month_number: month_number)
      next if month.future?
      month.recompute!
      month.save unless month.current?
    end
  end
end
