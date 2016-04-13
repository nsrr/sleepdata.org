# frozen_string_literal: true

namespace :domains do
  desc 'Fix how options object is saved'
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

  desc 'Migrate options to new database format'
  task migrate_options: :environment do
    puts "Domain Options: #{DomainOption.count}"
    Domain.find_each do |domain|
      domain.domain_options.destroy_all
      domain.options.each_with_index do |option, index|
        domain.domain_options.create(
          display_name: option['display_name'],
          value: option['value'],
          description: option['description'],
          missing: option['missing'].to_s == '1',
          position: index
        )
      end
    end
    puts "Domain Options: #{DomainOption.count}"
  end
end
