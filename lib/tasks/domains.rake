# frozen_string_literal: true

namespace :domains do
  desc 'Export Flow Limitation challenge to CSV'
  task fix_options: :environment do
    option_types = Domain.find_each.collect{ |d| d.options_before_type_cast.split("\n")[1] }.uniq
    puts option_types
    Domain.find_each do |domain|
      cleaned_options = domain.options.collect do |option|
        option.to_hash.with_indifferent_access
      end
      domain.update_column :options, cleaned_options
    end
    option_types = Domain.find_each.collect{ |d| d.options_before_type_cast.split("\n")[1] }.uniq
    puts option_types
  end
end
