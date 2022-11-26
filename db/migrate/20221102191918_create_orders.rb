class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.string :po_number
      t.string :po_state
      t.datetime :po_date
      t.datetime :po_changed_date
      t.datetime :po_state_changed_date
      t.string :po_type
      t.string :import_method_of_payment
      t.string :import_international_commercial_terms
      t.string :import_port_of_delivery
      t.string :import_containers
      t.text :import_shipping_instructions
      t.string :deal_code
      t.string :payment_method
      t.string :buying_party_id
      t.string :buying_address_name
      t.string :buying_address_line1
      t.string :buying_address_city
      t.string :buying_address_state_or_region
      t.string :buying_address_postal_code
      t.string :buying_address_country_code
      t.string :buying_address_phone
      t.string :selling_party_id
      t.string :ship_to_party_id
      t.string :ship_to_address_name
      t.string :ship_to_address_line1
      t.string :ship_to_address_city
      t.string :ship_to_address_state_or_region
      t.string :ship_to_address_postal_code
      t.string :ship_to_address_country_code
      t.string :ship_to_address_phone
      t.string :bill_to_party_id
      t.string :bill_to_address_name
      t.string :bill_to_address_line1
      t.string :bill_to_address_city
      t.string :bill_to_address_state_or_region
      t.string :bill_to_address_postal_code
      t.string :bill_to_address_country_code
      t.string :bill_to_address_phone
      t.string :tax_type
      t.string :tax_registration_number
      t.string :delivery_window

      t.timestamps
    end
  end
end
