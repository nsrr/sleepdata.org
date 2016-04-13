class CreateDomainOptions < ActiveRecord::Migration
  def change
    create_table :domain_options do |t|
      t.integer :domain_id
      t.string :display_name
      t.string :value
      t.text :description
      t.boolean :missing, null: false, default: false
      t.integer :position, null: false, default: 0

      t.timestamps null: false
    end
  end
end
