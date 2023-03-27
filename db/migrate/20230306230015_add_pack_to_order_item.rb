class AddPackToOrderItem < ActiveRecord::Migration[7.0]
  def change
    add_column :order_items, :pack, :integer
  end
end
