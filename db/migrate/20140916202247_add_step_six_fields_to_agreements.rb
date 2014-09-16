class AddStepSixFieldsToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :signature, :text
    add_column :agreements, :signature_print, :string
    add_column :agreements, :signature_date, :date
  end
end
