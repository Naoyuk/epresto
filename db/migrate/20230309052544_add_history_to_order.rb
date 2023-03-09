class AddHistoryToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :history, :string
    add_column :order_items, :history, :string
    add_column :order_item_acknowledgements, :history, :string
  end
end
