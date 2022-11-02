# frozen_string_literal: true

class Item < ApplicationRecord
  validates :item_code, presence: true
  validates :upc, presence: true
  validates :asin, presence: true

  enum availability_status: {
    Current: 0,
    Discontinued: 1,
    Future: 2
  }

  belongs_to :vendor

  def self.import(file, vendor_id)
    data = Roo::Spreadsheet.open(file)
    headers = data.row(1)
    data.each_with_index do |row, idx|
      next if idx.zero?

      item_params = Hash[[headers, row].transpose]
      item_params[:price] = row[6].delete('$').to_f
      item_params[:vendor_id] = vendor_id
      item = Item.new(item_params)

      if Item.exists?(asin: item.asin)
        item_to_update = Item.find_by(asin: item.asin)
        item_to_update_attributes = item_to_update.attributes.reject do |key|
          ['id', 'created_at', 'updated_at'].include?(key)
        end
        item_attributes = item.attributes.reject do |key|
          ['id', 'created_at', 'updated_at'].include?(key)
        end
        # debugger
        if item_to_update_attributes != item_attributes
          item_to_update.update(item_params)
        end
      else
        # debugger
        item.save
      end
    end
  end
end
