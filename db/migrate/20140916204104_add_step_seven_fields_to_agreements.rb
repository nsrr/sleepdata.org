class AddStepSevenFieldsToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :irb_evidence_type, :string, null: false, default: 'has_evidence'
    add_column :agreements, :irb, :string
  end
end
