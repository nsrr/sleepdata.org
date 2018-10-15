class CreateSearches < ActiveRecord::Migration[5.2]
  def change
    create_table :searches do |t|
      t.text :search
      t.integer :search_count, null: false, default: 0
      t.integer :results_count, null: false, default: 0
      t.index :search_count
      t.index :results_count
    end
  end
end
