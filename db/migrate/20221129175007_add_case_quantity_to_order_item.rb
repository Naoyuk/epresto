class AddCaseQuantityToOrderItem < ActiveRecord::Migration[7.0]
  def change
    add_column :order_items, :case_quantity, :integer
  end
end
