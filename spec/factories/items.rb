# frozen_string_literal: true

FactoryBot.define do
  factory :item do
    item_code { 'MyString' }
    upc { 'MyString' }
    title { 'MyString' }
    brand { 'MyString' }
    size { 1 }
    pack { 1 }
    price { 1.5 }
    z_price { 1.5 }
    stock { 1 }
    depertment { 'MyString' }
    availability_status { 1 }
    case_upc { 'MyString' }
    asin { 'MyString' }
    ean_upc { 'MyString' }
    model_number { 'MyString' }
    description { 'MyText' }
    replenishment_status { 1 }
    effective_date { '2022-10-19' }
    current_cost { 1.5 }
    cost { 1.5 }
    current_cost_currency { 'MyString' }
    cost_currency { 'MyString' }
  end
end
