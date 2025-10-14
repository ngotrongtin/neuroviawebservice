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

ActiveRecord::Schema[7.0].define(version: 2025_10_13_033809) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "mqtt_messages", force: :cascade do |t|
    t.string "topic"
    t.text "payload"
    t.integer "qos"
    t.datetime "received_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "username", limit: 50, null: false
    t.string "email", limit: 100, null: false
    t.text "password_hash", null: false
    t.string "full_name", limit: 100
    t.datetime "created_at", precision: nil, default: -> { "now()" }
    t.datetime "updated_at", precision: nil, default: -> { "now()" }
    t.index ["email"], name: "users_email_key", unique: true
    t.index ["username"], name: "users_username_key", unique: true
  end

end
