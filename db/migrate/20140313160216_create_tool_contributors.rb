class CreateToolContributors < ActiveRecord::Migration
  def change
    create_table :tool_contributors do |t|
      t.integer :tool_id
      t.integer :user_id

      t.timestamps
    end
  end
end
