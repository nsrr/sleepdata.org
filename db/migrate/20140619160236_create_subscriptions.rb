class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :topic_id
      t.integer :user_id
      t.boolean :subscribed, null: false, default: true

      t.timestamps
    end

    add_index :subscriptions, :topic_id
    add_index :subscriptions, :user_id
    add_index :subscriptions, [:topic_id, :user_id]
  end
end
