class AddTransitTimeToShipto < ActiveRecord::Migration[7.0]
  def change
    add_column :shiptos, :transit_time, :integer
  end
end
