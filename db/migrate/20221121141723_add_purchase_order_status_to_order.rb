class AddPurchaseOrderStatusToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :purchase_order_status, :integer
    add_column :orders, :last_updated_date, :datetime
    add_column :orders, :acknowledgement_date, :datetime
    add_column :orders, :selling_tax_type, :integer
    add_column :orders, :selling_tax_number, :string
    add_column :orders, :ship_to_tax_type, :integer
    add_column :orders, :ship_to_tax_number, :string
    add_column :orders, :bill_to_tax_type, :integer
    add_column :orders, :bill_to_tax_number, :string
  end
end
