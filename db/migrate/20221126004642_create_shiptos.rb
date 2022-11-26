class CreateShiptos < ActiveRecord::Migration[7.0]
  def change
    create_table :shiptos do |t|
      t.string :airport_code
      t.string :province

      t.timestamps
    end
  end
end
