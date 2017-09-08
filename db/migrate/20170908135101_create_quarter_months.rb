class CreateQuarterMonths < ActiveRecord::Migration[5.1]
  def change
    create_table :quarter_months do |t|
      t.integer :quarter_id
      t.integer :year, null: false
      t.integer :month_number, null: false
      t.bigint :regular_files, null: false, default: 0
      t.bigint :regular_file_size, null: false, default: 0
      t.bigint :regular_total_files, null: false, default: 0
      t.bigint :regular_total_file_size, null: false, default: 0
      t.index [:year, :month_number], unique: true
      t.index :quarter_id
      t.timestamps
    end
  end
end
