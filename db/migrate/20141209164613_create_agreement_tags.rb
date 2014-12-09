class CreateAgreementTags < ActiveRecord::Migration
  def change
    create_table :agreement_tags do |t|
      t.integer :agreement_id
      t.integer :tag_id
    end

    add_index :agreement_tags, :agreement_id
    add_index :agreement_tags, :tag_id
  end
end
