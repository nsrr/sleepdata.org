class AddReviewerUploadedToSupportingDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :supporting_documents, :reviewer_uploaded, :boolean, null: false, default: false
    add_index :supporting_documents, :reviewer_uploaded
  end
end
