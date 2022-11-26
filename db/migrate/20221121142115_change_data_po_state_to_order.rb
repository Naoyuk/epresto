class ChangeDataPoStateToOrder < ActiveRecord::Migration[7.0]
  def up
    change_column :orders, :po_state, :integer, using: "po_state::integer"
    change_column :orders, :po_type, :integer, using: "po_type::integer"
    change_column :orders, :payment_method, :integer, using: "payment_method::integer"
    change_column :orders, :tax_type, :integer, using: "tax_type::integer"
  end

  def down
    change_column :orders, :po_state, :string
    change_column :orders, :po_type, :string
    change_column :orders, :payment_method, :string
    change_column :orders, :tax_type, :string
  end
end
