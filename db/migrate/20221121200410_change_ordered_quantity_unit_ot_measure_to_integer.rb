class ChangeOrderedQuantityUnitOtMeasureToInteger < ActiveRecord::Migration[7.0]
  def up
    change_column :order_items, :ordered_quantity_unit_of_measure, :integer, using: "ordered_quantity_unit_of_measure::integer"
  end

  def down
    change_column :order_items, :ordered_quantity_unit_of_measure, :string
  end
end
