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

ActiveRecord::Schema[8.0].define(version: 2025_03_06_065119) do
  create_table "relationships", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "follower_id", null: false
    t.bigint "followed_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_user_id"], name: "index_relationships_on_followed_user_id"
    t.index ["follower_id", "followed_user_id"], name: "index_relationships_on_follower_and_followed", unique: true
    t.index ["follower_id"], name: "index_relationships_on_follower_id"
  end

  create_table "sleep_records", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "sleep_at", null: false
    t.datetime "wake_up_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sleep_at"], name: "index_sleep_records_on_sleep_at"
    t.index ["user_id"], name: "index_sleep_records_on_user_id"
    t.index ["wake_up_at"], name: "index_sleep_records_on_wake_up_at"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "relationships", "users", column: "followed_user_id"
  add_foreign_key "relationships", "users", column: "follower_id"
  add_foreign_key "sleep_records", "users"
end
