class ChangeFormIdToBigint < ActiveRecord::Migration[6.0]
  def up
    change_column :forms, :id, :bigint

    change_column :variable_forms, :form_id, :bigint
  end

  def down
    change_column :forms, :id, :integer

    change_column :variable_forms, :form_id, :integer
  end
end
