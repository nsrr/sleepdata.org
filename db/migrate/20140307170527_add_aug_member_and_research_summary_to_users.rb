class AddAugMemberAndResearchSummaryToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :aug_member, :boolean, null: false, default: false
    add_column :users, :research_summary, :text
  end
end
