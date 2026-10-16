# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_09_03_110600) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_line_3"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "country_code"
    t.string "company_name"
    t.integer "category", default: 0
    t.bigint "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.index ["order_id"], name: "index_addresses_on_order_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "code"], name: "index_countries_on_name_and_code"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "line_items", force: :cascade do |t|
    t.string "variant_title"
    t.integer "quantity"
    t.bigint "shopify_variant_id"
    t.bigint "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_line_items_on_order_id"
  end

  create_table "order_uploads", force: :cascade do |t|
    t.integer "source", default: 0
    t.string "source_email"
    t.integer "status", default: 0
    t.boolean "send_receipt", default: true
    t.bigint "shop_id"
    t.bigint "shopify_product_id"
    t.string "shopify_product_title"
    t.boolean "notify_developer", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.string "errors_file_file_name"
    t.string "errors_file_content_type"
    t.integer "errors_file_file_size"
    t.datetime "errors_file_updated_at"
    t.string "customer_name"
    t.index ["shop_id"], name: "index_order_uploads_on_shop_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "shopify_product_id"
    t.bigint "shopify_order_id"
    t.string "customer_email"
    t.bigint "order_upload_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "redacted_at"
    t.string "shopify_name"
    t.jsonb "note_attributes", default: {}
    t.index ["order_upload_id"], name: "index_orders_on_order_upload_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "shopify_id"
    t.string "shopify_title"
    t.bigint "shop_id"
    t.boolean "store_front_form"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_products_on_shop_id"
    t.index ["shopify_id", "shop_id"], name: "index_products_on_shopify_id_and_shop_id", unique: true
  end

  create_table "shops", force: :cascade do |t|
    t.string "shopify_domain", null: false
    t.string "shopify_token", null: false
    t.string "shopify_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "shopify_owner"
    t.string "contact_emails", default: "webstores@socialimprints.com"
    t.index ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true
  end

  create_table "states", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_states_on_country_id"
  end

  create_table "variants", force: :cascade do |t|
    t.string "shopify_id"
    t.string "shopify_title"
    t.bigint "product_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_variants_on_product_id"
  end

  add_foreign_key "addresses", "orders"
  add_foreign_key "line_items", "orders"
  add_foreign_key "order_uploads", "shops"
  add_foreign_key "orders", "order_uploads"
end
