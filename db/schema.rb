# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160614174540) do

  create_table "adjustment_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "adjustments", force: :cascade do |t|
    t.integer  "product_id"
    t.integer  "adjustment_type_id"
    t.integer  "adjusted_quantity"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "adjustments", ["adjustment_type_id"], name: "index_adjustments_on_adjustment_type_id"
  add_index "adjustments", ["product_id"], name: "index_adjustments_on_product_id"

  create_table "amazon_statements", force: :cascade do |t|
    t.string   "period"
    t.decimal  "deposit_total"
    t.string   "status"
    t.string   "settlement_id"
    t.text     "summary"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "report_id"
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "qbo_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "configurations", force: :cascade do |t|
    t.string   "primary_marketplace_id"
    t.string   "merchant_id"
    t.string   "auth_token"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "country"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "credentials", force: :cascade do |t|
    t.string   "primary_marketplace_id"
    t.string   "merchant_id"
    t.string   "auth_token"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "expense_accounts", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "qbo_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "expense_receipts", force: :cascade do |t|
    t.string   "description"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "bank_account_id"
  end

  add_index "expense_receipts", ["bank_account_id"], name: "index_expense_receipts_on_bank_account_id"

  create_table "expenses", force: :cascade do |t|
    t.integer  "expense_account_id"
    t.string   "description"
    t.float    "amount"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "expenses", ["expense_account_id"], name: "index_expenses_on_expense_account_id"

  create_table "order_items", force: :cascade do |t|
    t.integer  "quantity"
    t.integer  "order_id"
    t.integer  "product_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.float    "cost"
    t.float    "average_cost"
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id"
  add_index "order_items", ["product_id"], name: "index_order_items_on_product_id"

  create_table "orders", force: :cascade do |t|
    t.string   "name"
    t.integer  "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "user_date"
  end

  add_index "orders", ["contact_id"], name: "index_orders_on_contact_id"

  create_table "payments", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.string   "upc"
    t.float    "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "qbo_id"
  end

  create_table "qbo_configs", force: :cascade do |t|
    t.string   "token"
    t.string   "secret"
    t.string   "realm_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sales", force: :cascade do |t|
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "quantity"
    t.integer  "sales_receipt_id"
    t.decimal  "amount"
    t.decimal  "rate"
    t.integer  "product_id"
    t.string   "description"
    t.integer  "qbo_id"
  end

  add_index "sales", ["product_id"], name: "index_sales_on_product_id"
  add_index "sales", ["sales_receipt_id"], name: "index_sales_on_sales_receipt_id"

  create_table "sales_receipts", force: :cascade do |t|
    t.integer  "contact_id"
    t.integer  "payment_id"
    t.datetime "user_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sales_receipts", ["contact_id"], name: "index_sales_receipts_on_contact_id"
  add_index "sales_receipts", ["payment_id"], name: "index_sales_receipts_on_payment_id"

end
