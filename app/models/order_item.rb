# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item,
             optional: true,
             primary_key: :asin,
             foreign_key: :amazon_product_identifier
  has_many :acks, class_name: 'OrderItemAcknowledgement'

  # definitions of enum
  enum ordered_quantity_unit_of_measure: {
    Cases: 0,
    Eaches: 1
  }

  def convert_case_quantity
    # リレーションが成立しない、またはItem.caseがnilの場合はcase_quantityはnil
    if self.item&.Case?
      self.case_quantity = self.ordered_quantity_amount
    elsif self.item&.Each? && !self.item&.pack.nil?
      unless self.ordered_quantity_amount.nil?
        self.case_quantity = self.ordered_quantity_amount / self.item.pack
      end
    end
  end

  def quantity_correction
    if self.item.Case?
      self.ordered_quantity_amount
    else
      if self.case_quantity.nil? || self.case_quantity == 0
        self.ordered_quantity_amount / self.item.pack
      else
        self.ordered_quantity_amount / self.case_quantity
      end
    end
  end
end
