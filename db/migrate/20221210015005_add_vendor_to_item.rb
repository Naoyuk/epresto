class AddVendorToItem < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :vendor, :string
  end
end
