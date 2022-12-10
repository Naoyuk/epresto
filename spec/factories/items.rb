# frozen_string_literal: true

FactoryBot.define do
  factory :item do
    item_code { 'A123' }
    upc { 'B123' }
    title { 'Sample Item' }
    brand { 'Sample Brand' }
    size { 1 }
    pack { 6 }
    price { 1.5 }
    z_pricing { 1.5 }
    stock { 10 }
    dept { 'Sample Department' }
    status { 1 }
    asin { 'D123' }
    model_number { 'F123' }
    description { 'Sample Description' }
    association :vendor
  end
end
