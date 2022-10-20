class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :item_code
      t.string :upc
      t.string :title
      t.string :brand
      t.integer :size
      t.integer :pack
      t.float :price
      t.float :z_price
      t.integer :stock
      t.string :depertment
      t.integer :availability_status
      t.string :case_upc
      t.string :ASIN
      t.string :ean_upc
      t.string :model_number
      t.text :description
      t.integer :replenishment_status
      t.date :effective_date
      t.float :current_cost
      t.float :cost
      t.string :current_cost_currency
      t.string :cost_currency

      t.timestamps
    end
  end
end
