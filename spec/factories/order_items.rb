# frozen_string_literal: true

FactoryBot.define do
  factory :order_item do
    item_seq_number { 'MyString' }
    amazon_product_identifier { 'MyString' }
    vendor_product_identifier { 'MyString' }
    ordered_quantity_amount { 1 }
    ordered_quantity_unit_of_measure { 'MyString' }
    ordered_quantity_unit_size { 1 }
    back_order_allowed { false }
    netcost_amount { 1.5 }
    netcost_currency_code { 'MyString' }
    listprice_amount { 1.5 }
    listprice_currency_code { 'MyString' }
    order { nil }
  end
end
