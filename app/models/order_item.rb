# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item, optional: true
  has_many :acks, class_name: 'OrderItemAcknowledgement'

  # definitions of enum
  enum ordered_quantity_unit_of_measure: {
    Cases: 0,
    Eaches: 1
  }

  def convert_case_quantity
    if self.item.Case?
      self.case_quantity = self.ordered_quantity_amount
    else
      self.case_quantity = self.ordered_quantity_amount / self.item.pack
    end
    self.save
  end
end
