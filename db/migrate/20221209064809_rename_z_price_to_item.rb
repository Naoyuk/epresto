class RenameZPriceToItem < ActiveRecord::Migration[7.0]
  def change
    rename_column :items, :z_price, :z_pricing
    rename_column :items, :depertment, :dept
    rename_column :items, :availability_status, :status
  end
end
