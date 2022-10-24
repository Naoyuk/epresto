class ChangeDataReplenishmentStatusToItem < ActiveRecord::Migration[7.0]
  def change
    change_column :items, :replenishment_status, :string
  end
end
