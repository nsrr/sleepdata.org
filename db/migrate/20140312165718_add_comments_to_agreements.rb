class AddCommentsToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :comments, :text
  end
end
