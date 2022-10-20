class AddVendorIdToItems < ActiveRecord::Migration[7.0]
  def change
    add_reference :items, :vendor, null: false, foreign_key: true
  end
end
