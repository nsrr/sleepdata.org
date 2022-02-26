class AddPublishedToPages < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :published, :boolean, null: false, default: false
    add_index :pages, :published
  end
end
