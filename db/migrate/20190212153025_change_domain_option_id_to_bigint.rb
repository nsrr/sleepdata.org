class ChangeDomainOptionIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :domain_options, :id, :bigint
  end

  def down
    change_column :domain_options, :id, :integer
  end
end
