# frozen_string_literal: true

namespace :variables do
  # TODO: Remove the following in 0.23.0
  desc 'Update variable labels'
  task update_labels: :environment do
    puts "VariableLabel: #{VariableLabel.count}"
    Variable.find_each do |variable|
      variable.labels.each do |label|
        variable.variable_labels.where(name: label).first_or_create name: label
      end
    end
    puts "VariableLabel: #{VariableLabel.count}"
  end
  # TODO: End
end
