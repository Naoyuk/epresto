class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :order_items do |t|
      t.string :item_seq_number
      t.string :amazon_product_identifier
      t.string :vendor_product_identifier
      t.integer :ordered_quantity_amount
      t.string :ordered_quantity_unit_of_measure
      t.integer :ordered_quantity_unit_size
      t.boolean :back_order_allowed
      t.float :netcost_amount
      t.string :netcost_currency_code
      t.float :listprice_amount
      t.string :listprice_currency_code
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
