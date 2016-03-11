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

ActiveRecord::Schema.define(version: 20160310200441) do

  create_table "instedd_telemetry_counters", force: :cascade do |t|
    t.integer "period_id"
    t.string  "bucket"
    t.text    "key_attributes"
    t.integer "count",               default: 0
    t.string  "key_attributes_hash"
  end

  add_index "instedd_telemetry_counters", ["bucket", "key_attributes_hash", "period_id"], name: "instedd_telemetry_counters_unique_fields", unique: true

  create_table "instedd_telemetry_periods", force: :cascade do |t|
    t.datetime "beginning"
    t.datetime "end"
    t.datetime "stats_sent_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "lock_owner"
    t.datetime "lock_expiration"
  end

  create_table "instedd_telemetry_set_occurrences", force: :cascade do |t|
    t.integer "period_id"
    t.string  "bucket"
    t.text    "key_attributes"
    t.string  "element"
    t.string  "key_attributes_hash"
  end

  add_index "instedd_telemetry_set_occurrences", ["bucket", "key_attributes_hash", "element", "period_id"], name: "instedd_telemetry_set_occurrences_unique_fields", unique: true

  create_table "instedd_telemetry_settings", force: :cascade do |t|
    t.string "key"
    t.string "value"
  end

  add_index "instedd_telemetry_settings", ["key"], name: "index_instedd_telemetry_settings_on_key", unique: true

  create_table "instedd_telemetry_timespans", force: :cascade do |t|
    t.string   "bucket"
    t.text     "key_attributes"
    t.datetime "since"
    t.datetime "until"
    t.string   "key_attributes_hash"
  end

  add_index "instedd_telemetry_timespans", ["bucket", "key_attributes_hash"], name: "instedd_telemetry_timespans_unique_fields", unique: true

end
