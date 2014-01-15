class CreateAgreements < ActiveRecord::Migration
  def change
    create_table :agreements do |t|
      t.integer :user_id
      t.string :dua
      t.string :status
      t.text :history
      t.date :approval_date
      t.date :expiration_date
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
