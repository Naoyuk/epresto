# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_12_10_015005) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "items", force: :cascade do |t|
    t.string "item_code"
    t.string "upc"
    t.string "title"
    t.string "brand"
    t.integer "size"
    t.integer "pack"
    t.float "price"
    t.float "z_pricing"
    t.integer "stock"
    t.string "dept"
    t.integer "status"
    t.string "mixed_code"
    t.string "asin"
    t.string "model_number"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vendor_id", null: false
    t.boolean "case"
    t.string "vendor_code"
    t.string "vendor_sku"
    t.string "product_type"
    t.string "item_name"
    t.string "brand_name"
    t.string "external_product_id"
    t.string "external_product_id_type"
    t.string "merchant_suggested_asin"
    t.string "ean"
    t.string "gtin"
    t.string "vendor"
    t.index ["vendor_id"], name: "index_items_on_vendor_id"
  end

  create_table "order_item_acknowledgements", force: :cascade do |t|
    t.integer "acknowledgement_code"
    t.integer "acknowledged_quantity_amount"
    t.integer "acknowledged_quantity_unit_of_measure"
    t.integer "acknowledged_quantity_unit_size"
    t.bigint "order_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "scheduled_ship_date"
    t.datetime "scheduled_delivery_date"
    t.integer "rejection_reason"
    t.index ["order_item_id"], name: "index_order_item_acknowledgements_on_order_item_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.string "item_seq_number"
    t.string "amazon_product_identifier"
    t.string "vendor_product_identifier"
    t.integer "ordered_quantity_amount"
    t.integer "ordered_quantity_unit_of_measure"
    t.integer "ordered_quantity_unit_size"
    t.boolean "back_order_allowed"
    t.float "netcost_amount"
    t.string "netcost_currency_code"
    t.float "listprice_amount"
    t.string "listprice_currency_code"
    t.bigint "order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "item_id"
    t.integer "case_quantity"
    t.index ["item_id"], name: "index_order_items_on_item_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "po_number"
    t.integer "po_state"
    t.datetime "po_date"
    t.datetime "po_changed_date"
    t.datetime "po_state_changed_date"
    t.integer "po_type"
    t.string "import_method_of_payment"
    t.string "import_international_commercial_terms"
    t.string "import_port_of_delivery"
    t.string "import_containers"
    t.text "import_shipping_instructions"
    t.string "deal_code"
    t.integer "payment_method"
    t.string "buying_party_id"
    t.string "buying_address_name"
    t.string "buying_address_line1"
    t.string "buying_address_city"
    t.string "buying_address_state_or_region"
    t.string "buying_address_postal_code"
    t.string "buying_address_country_code"
    t.string "buying_address_phone"
    t.string "selling_party_id"
    t.string "ship_to_party_id"
    t.string "ship_to_address_name"
    t.string "ship_to_address_line1"
    t.string "ship_to_address_city"
    t.string "ship_to_address_state_or_region"
    t.string "ship_to_address_postal_code"
    t.string "ship_to_address_country_code"
    t.string "ship_to_address_phone"
    t.string "bill_to_party_id"
    t.string "bill_to_address_name"
    t.string "bill_to_address_line1"
    t.string "bill_to_address_city"
    t.string "bill_to_address_state_or_region"
    t.string "bill_to_address_postal_code"
    t.string "bill_to_address_country_code"
    t.string "bill_to_address_phone"
    t.integer "buying_tax_type"
    t.string "buying_tax_number"
    t.string "delivery_window"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vendor_id", null: false
    t.string "selling_address_name"
    t.string "selling_address_line1"
    t.string "selling_address_line2"
    t.string "selling_address_line3"
    t.string "selling_address_city"
    t.string "selling_address_district"
    t.string "selling_address_state_or_region"
    t.string "selling_address_postal_code"
    t.string "selling_address_country_code"
    t.string "selling_address_phone"
    t.string "buying_address_line2"
    t.string "buying_address_line3"
    t.string "buying_address_district"
    t.string "ship_to_address_line2"
    t.string "ship_to_address_line3"
    t.string "ship_to_address_district"
    t.string "bill_to_address_line2"
    t.string "bill_to_address_line3"
    t.string "bill_to_address_district"
    t.string "ship_window"
    t.integer "po_status"
    t.datetime "last_updated_date"
    t.datetime "acknowledgement_date"
    t.integer "selling_tax_type"
    t.string "selling_tax_number"
    t.integer "ship_to_tax_type"
    t.string "ship_to_tax_number"
    t.integer "bill_to_tax_type"
    t.string "bill_to_tax_number"
    t.datetime "ship_window_from"
    t.datetime "ship_window_to"
    t.bigint "shipto_id"
    t.index ["shipto_id"], name: "index_orders_on_shipto_id"
    t.index ["vendor_id"], name: "index_orders_on_vendor_id"
  end

  create_table "shiptos", force: :cascade do |t|
    t.string "location_code"
    t.string "province"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "customer_name"
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.string "postal_code"
    t.string "contact_name1"
    t.string "email1"
    t.string "phone1"
    t.string "contact_name2"
    t.string "email2"
    t.string "phone2"
    t.boolean "send_report"
    t.boolean "visu_email"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vendor_id"
    t.string "name"
    t.boolean "sysadmin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["vendor_id"], name: "index_users_on_vendor_id"
  end

  create_table "vendors", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "customer_code"
  end

  add_foreign_key "items", "vendors"
  add_foreign_key "order_item_acknowledgements", "order_items"
  add_foreign_key "order_items", "items"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "shiptos"
  add_foreign_key "orders", "vendors"
  add_foreign_key "users", "vendors"
end
