FactoryBot.define do
  factory :order_item_acknowledgement do
    acknowledgement_code { 1 }
    acknowledged_quantity_amount { 1 }
    acknowledged_quantity_unit_of_measure { 1 }
    acknowledged_quantity_unit_size { 1 }
    OrderItem { nil }
  end
end
