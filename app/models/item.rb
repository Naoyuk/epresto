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

  enum replenishment_status: {
    Active: 0,
    Obsolete: 1
  }

  belongs_to :vendor
end
