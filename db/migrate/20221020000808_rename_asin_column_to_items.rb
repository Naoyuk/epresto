class RenameAsinColumnToItems < ActiveRecord::Migration[7.0]
  def change
    rename_column :items, :ASIN, :asin
  end
end
