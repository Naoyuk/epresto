# frozen_string_literal: true

Shipto.create!(
  location_code: 'YYZ4',
  customer_name: 'Amazon Brampton, ON - YYZ5',
  address_line1: '8050 Heritage Road',
  city: 'Brampton',
  province: 'ON',
  postal_code: 'L6Y 0C9',
  contact_name1: 'Brampton, ON',
  send_report: false,
  visu_email: true
)
Shipto.create!(
  location_code: 'YYC1',
  customer_name: 'Amazon Calgary, AB - YYC2',
  address_line1: '293069 Colonel Robertson Way',
  city: 'Calgary',
  province: 'AB',
  postal_code: 'T4A 1C6',
  contact_name1: 'Calgary, AB',
  send_report: false,
  visu_email: true
)
Shipto.create!(
  location_code: 'YVR2',
  customer_name: 'Amazon Delta, BC - YVR3',
  address_line1: '450 Derwent PL',
  city: 'Delta',
  province: 'BC',
  postal_code: 'V3M 5Y9',
  contact_name1: 'Delta, BC',
  send_report: false,
  visu_email: true
)
Shipto.create!(
  location_code: 'YYZ7',
  customer_name: 'Amazon Bolton, ON - YYZ8',
  address_line1: '12724 Coleraine Drive',
  city: 'Bolton',
  province: 'ON',
  postal_code: 'L7E 4L8',
  contact_name1: 'Bolton, ON',
  send_report: false,
  visu_email: true
)
Shipto.create!(
  location_code: 'YVR4',
  customer_name: 'Amazon Tsawwassen, BC - YVR5',
  address_line1: '4189 Salish Sea Way',
  city: 'Tsawwassen',
  province: 'BC',
  postal_code: 'V4M 0B9',
  contact_name1: 'Tsawwassen, BC',
  send_report: false,
  visu_email: true
)
Shipto.create!(
  location_code: 'YYZ2',
  customer_name: 'Amazon Milton, ON - YYZ3',
  address_line1: '2750 Peddie Rd',
  city: 'Milton',
  province: 'ON',
  postal_code: 'L9T 0K1',
  contact_name1: 'Milton, ON',
  send_report: false,
  visu_email: true
)
Shipto.create!(
  location_code: 'YYZ1',
  customer_name: 'Amazon Mississauga, ON - YYZ2',
  address_line1: '6363 Millcreek Drive',
  city: 'Mississauga',
  province: 'ON',
  postal_code: 'L5N 1L8',
  contact_name1: 'Mississauga, ON',
  send_report: false,
  visu_email: true
)
Shipto.create!(
  location_code: 'YOW1',
  customer_name: 'Amazon Navan, ON - YOW2',
  address_line1: '5225 Boundary Road',
  city: 'Navan',
  province: 'ON',
  postal_code: 'K4B 0L3',
  contact_name1: 'Navan, ON',
  send_report: false,
  visu_email: true
)
Shipto.create!(
  location_code: 'YYZ9',
  customer_name: 'Amazon Scarborough, ON - YYZ10',
  address_line1: '6351 Steeles Ave E',
  city: 'Scarborough',
  province: 'ON',
  postal_code: 'M1X 1N5',
  contact_name1: 'Scarborough, ON',
  send_report: false,
  visu_email: true
)
Shipto.create!(
  location_code: 'YEG1',
  customer_name: 'Amazon Nisku, AB - YEG2',
  address_line1: '1440 39 AVE',
  city: 'Nisku',
  province: 'AB',
  postal_code: 'T9E 0B4',
  contact_name1: 'Nisku, AB',
  send_report: false,
  visu_email: true
)
Shipto.create!(
  location_code: 'YXX2',
  customer_name: 'Amazon Richmond, BC - YXX3',
  address_line1: '16131 Blundell Rd',
  city: 'Richmond',
  province: 'BC',
  postal_code: 'V6W 0A3',
  contact_name1: 'Richmond, BC',
  send_report: false,
  visu_email: true
)
Shipto.create!(
  location_code: 'YHM1',
  customer_name: 'Amazon Mount Hope, ON - YHM2',
  address_line1: '110 Aeropark Blvd',
  city: 'Mount Hope',
  province: 'ON',
  postal_code: 'L0R 1W1',
  contact_name1: 'Mount Hope, ON'
)
Shipto.create!(
  location_code: 'YOO1',
  customer_name: 'Amazon Ajax, ON -  YOO2',
  address_line1: '789 Salem Rd N',
  city: 'Ajax',
  province: 'ON',
  postal_code: 'L1Z 0J2',
  contact_name1: 'Ajax, ON'
)
Shipto.create!(
  location_code: 'YOW3',
  customer_name: 'Amazon Nepean, ON - YOW4',
  address_line1: '222 Citigate Drive',
  city: 'Nepean',
  province: 'ON',
  postal_code: 'K2J 7C7',
  contact_name1: 'Nepean, ON'
)
Shipto.create!(
  location_code: 'YYZ3',
  customer_name: 'Amazon Winston, ON - YYZ4',
  address_line1: '7995 Winston Churchill Blvd.',
  city: 'Winston',
  province: 'ON',
  postal_code: 'L6Y 5Z4',
  contact_name1: 'Winston, ON'
)

Vendor.create!(name: 'ePresto')
Vendor.create!(name: 'CCW')

user = User.new(name: 'admin', email: 'admin@example.com', sysadmin: true, vendor_id: 1)
user.password = 'password'
user.save
