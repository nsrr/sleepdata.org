class RemoveIrbEvidenceTypeFromAgreements < ActiveRecord::Migration[5.2]
  def change
    remove_column :agreements, :irb_evidence_type, :string, null: false, default: "has_evidence"
  end
end
