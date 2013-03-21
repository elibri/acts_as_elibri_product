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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130321131042) do

  create_table "contributors", :force => true do |t|
    t.integer  "import_id"
    t.integer  "product_id"
    t.string   "role_name"
    t.string   "role"
    t.string   "from_language"
    t.string   "full_name"
    t.string   "title"
    t.string   "first_name"
    t.string   "last_name_prefix"
    t.string   "last_name"
    t.string   "last_name_postfix"
    t.text     "biography"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "imprints", :force => true do |t|
    t.integer  "product_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "product_texts", :force => true do |t|
    t.integer  "import_id"
    t.integer  "product_id"
    t.text     "text"
    t.string   "text_type"
    t.string   "text_author"
    t.string   "source_title"
    t.string   "resource_link"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "products", :force => true do |t|
    t.string   "record_reference",                     :null => false
    t.string   "isbn"
    t.string   "title"
    t.string   "full_title"
    t.string   "trade_title"
    t.string   "original_title"
    t.integer  "publication_year"
    t.integer  "publication_month"
    t.integer  "publication_day"
    t.integer  "number_of_pages"
    t.integer  "duration"
    t.integer  "width"
    t.integer  "height"
    t.string   "cover_type"
    t.string   "edition_statement"
    t.integer  "audience_age_from"
    t.integer  "audience_age_to"
    t.string   "price_amount"
    t.integer  "vat"
    t.string   "pkwiu"
    t.string   "current_state"
    t.string   "product_form"
    t.boolean  "preview_exists",    :default => false
    t.boolean  "no_contributor",    :default => false
    t.boolean  "unnamed_persons",   :default => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.text     "old_xml"
    t.string   "cover_link"
    t.integer  "publisher_id"
  end

  create_table "publishers", :force => true do |t|
    t.string "name"
  end

  create_table "related_products", :force => true do |t|
    t.integer  "product_id"
    t.string   "related_record_reference"
    t.string   "onix_code"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

end
