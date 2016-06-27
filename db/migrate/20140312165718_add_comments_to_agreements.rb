class AddCommentsToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :agreements, :comments, :text
  end
end
