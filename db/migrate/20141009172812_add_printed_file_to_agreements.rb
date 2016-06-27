class AddPrintedFileToAgreements < ActiveRecord::Migration[4.2]
  def change
    add_column :agreements, :printed_file, :string
  end
end
