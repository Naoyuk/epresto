class AddEanToItem < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :ean, :string
    add_column :items, :gtin, :string
  end
end
