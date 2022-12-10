class RenameCaseUpcToItem < ActiveRecord::Migration[7.0]
  def change
    rename_column :items, :case_upc, :mixed_code
  end
end
