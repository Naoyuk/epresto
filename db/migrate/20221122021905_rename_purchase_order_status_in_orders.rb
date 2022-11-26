class RenamePurchaseOrderStatusInOrders < ActiveRecord::Migration[7.0]
  def change
    rename_column :orders, :purchase_order_status, :po_status
  end
end
