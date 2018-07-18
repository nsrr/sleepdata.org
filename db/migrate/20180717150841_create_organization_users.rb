class CreateOrganizationUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :organization_users do |t|
      t.integer :organization_id
      t.integer :user_id
      t.boolean :editor, null: false, default: false
      t.string :review_role, null: false, default: "none"
      t.integer :creator_id
      t.string :invite_email
      t.string :invite_token
      t.timestamps
      t.index [:organization_id, :user_id], unique: true
      t.index :creator_id
      t.index :invite_token, unique: true
    end
  end
end
