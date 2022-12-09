class RenameVendorSkuToItem < ActiveRecord::Migration[7.0]
  def change
    rename_column :items, :vendor_sKU, :vendor_sku
  end
end
