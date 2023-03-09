class AddTitleToOrderItem < ActiveRecord::Migration[7.0]
  def change
    add_column :order_items, :title, :string
    add_column :order_items, :availability, :integer
  end
end
