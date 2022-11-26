class CreateOrderItemAcknowledgements < ActiveRecord::Migration[7.0]
  def change
    create_table :order_item_acknowledgements do |t|
      t.integer :acknowledgement_code
      t.integer :acknowledged_quantity_amount
      t.integer :acknowledged_quantity_unit_of_measure
      t.integer :acknowledged_quantity_unit_size
      t.references :order_item, null: false, foreign_key: true

      t.timestamps
    end
  end
end
