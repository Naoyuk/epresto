# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :vendor

  def self.import(file, vendor_id)
    # implement import method
  end
end
