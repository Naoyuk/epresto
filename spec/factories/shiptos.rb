FactoryBot.define do
  factory :shipto do
    location_code { "MyString" }
    province { "MyString" }
    customer_name { "MyString" }
    address_line1 { "MyString" }
    address_line2 { "MyString" }
    city { "MyString" }
    postal_code { "MyString" }
    contact_name1 { "MyString" }
    email1 { "MyString" }
    phone1 { "MyString" }
    contact_name2 { "MyString" }
    email2 { "MyString" }
    phone2 { "MyString" }
    send_report { false }
    visu_email { false }
  end
end
