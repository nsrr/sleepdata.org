class AddPrintedFileToAgreements < ActiveRecord::Migration
  def change
    add_column :agreements, :printed_file, :string
  end
end
