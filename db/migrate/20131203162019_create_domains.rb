class CreateDomains < ActiveRecord::Migration[4.2]
  def change
    create_table :domains do |t|
      t.text :folder
      t.string :name
      t.text :options
      t.integer :dataset_id
      t.string :version

      t.timestamps
    end

    add_index :domains, :dataset_id
  end
end
