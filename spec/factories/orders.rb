# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    po_number { 'MyString' }
    po_state { 'MyString' }
    po_date { '2022-11-02 12:19:18' }
    po_changed_date { '2022-11-02 12:19:18' }
    po_state_changed_date { '2022-11-02 12:19:18' }
    po_type { 'MyString' }
    import_method_of_payment { 'MyString' }
    import_international_commercial_terms { 'MyString' }
    import_port_of_delivery { 'MyString' }
    import_containers { 'MyString' }
    import_shipping_instructions { 'MyText' }
    deal_code { 'MyString' }
    payment_method { 'MyString' }
    buying_party_id { 'MyString' }
    buying_address_name { 'MyString' }
    buying_address_line1 { 'MyString' }
    buying_address_city { 'MyString' }
    buying_address_state_or_region { 'MyString' }
    buying_address_postal_code { 'MyString' }
    buying_address_country_code { 'MyString' }
    buying_address_phone { 'MyString' }
    selling_party_id { 'MyString' }
    ship_to_party_id { 'MyString' }
    ship_to_address_name { 'MyString' }
    ship_to_address_line1 { 'MyString' }
    ship_to_address_city { 'MyString' }
    ship_to_address_state_or_region { 'MyString' }
    ship_to_address_postal_code { 'MyString' }
    ship_to_address_country_code { 'MyString' }
    ship_to_address_phone { 'MyString' }
    bill_to_party_id { 'MyString' }
    bill_to_address_name { 'MyString' }
    bill_to_address_line1 { 'MyString' }
    bill_to_address_city { 'MyString' }
    bill_to_address_state_or_region { 'MyString' }
    bill_to_address_postal_code { 'MyString' }
    bill_to_address_country_code { 'MyString' }
    bill_to_address_phone { 'MyString' }
    tax_type { 'MyString' }
    tax_registration_number { 'MyString' }
    delivery_window { 'MyString' }
    association :vendor
  end
end
