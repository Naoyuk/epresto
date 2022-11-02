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

ActiveRecord::Schema[7.0].define(version: 2022_11_02_200440) do
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
    t.float "z_price"
    t.integer "stock"
    t.string "depertment"
    t.integer "availability_status"
    t.string "case_upc"
    t.string "asin"
    t.string "ean_upc"
    t.string "model_number"
    t.text "description"
    t.string "replenishment_status"
    t.date "effective_date"
    t.float "current_cost"
    t.float "cost"
    t.string "current_cost_currency"
    t.string "cost_currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vendor_id", null: false
    t.index ["vendor_id"], name: "index_items_on_vendor_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "po_number"
    t.string "po_state"
    t.datetime "po_date"
    t.datetime "po_changed_date"
    t.datetime "po_state_changed_date"
    t.string "po_type"
    t.string "import_method_of_payment"
    t.string "import_international_commercial_terms"
    t.string "import_port_of_delivery"
    t.string "import_containers"
    t.text "import_shipping_instructions"
    t.string "deal_code"
    t.string "payment_method"
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
    t.string "tax_type"
    t.string "tax_registration_number"
    t.string "delivery_window"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vendor_id", null: false
    t.index ["vendor_id"], name: "index_orders_on_vendor_id"
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
  end

  add_foreign_key "items", "vendors"
  add_foreign_key "orders", "vendors"
  add_foreign_key "users", "vendors"
end
