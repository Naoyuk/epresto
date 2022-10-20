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
    z_price { 1.5 }
    stock { 10 }
    depertment { 'Sample Department' }
    availability_status { 1 }
    case_upc { 'C123' }
    asin { 'D123' }
    ean_upc { 'E123' }
    model_number { 'F123' }
    description { 'Sample Description' }
    replenishment_status { 1 }
    effective_date { '2022-10-19' }
    current_cost { 1.5 }
    cost { 1.5 }
    current_cost_currency { 'CAD' }
    cost_currency { 'CAD' }
    association :vendor
  end
end
