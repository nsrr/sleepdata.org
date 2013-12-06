class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :name
      t.text :variable_ids

      t.timestamps
    end
  end
end
