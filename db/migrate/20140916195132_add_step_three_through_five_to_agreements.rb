class AddStepThreeThroughFiveToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :has_read_step3, :boolean, null: false, default: false
    add_column :agreements, :posting_permission, :string, null: false, default: 'all'
    add_column :agreements, :has_read_step5, :boolean, null: false, default: false
  end
end
