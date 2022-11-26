class RenameTaxTypeToBuyingTaxTypeInOrders < ActiveRecord::Migration[7.0]
  def change
    rename_column :orders, :tax_type, :buying_tax_type
    rename_column :orders, :tax_registration_number, :buying_tax_number
  end
end
