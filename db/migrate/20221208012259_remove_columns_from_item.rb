class RemoveColumnsFromItem < ActiveRecord::Migration[7.0]
  def change
    remove_column :items, :ean_upc
    remove_column :items, :replenishment_status
    remove_column :items, :effective_date
    remove_column :items, :current_cost
    remove_column :items, :current_cost_currency
    remove_column :items, :cost
    remove_column :items, :cost_currency
  end
end
