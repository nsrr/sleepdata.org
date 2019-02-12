class ChangeAgreementTagIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :agreement_tags, :id, :bigint
  end

  def down
    change_column :agreement_tags, :id, :integer
  end
end
