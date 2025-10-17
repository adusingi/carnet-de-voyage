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

ActiveRecord::Schema[8.0].define(version: 2025_10_17_145720) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "map_tags", force: :cascade do |t|
    t.bigint "map_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["map_id"], name: "index_map_tags_on_map_id"
    t.index ["tag_id"], name: "index_map_tags_on_tag_id"
  end

  create_table "maps", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "destination"
    t.integer "privacy", default: 0
    t.integer "places_count", default: 0
    t.text "original_text"
    t.text "processed_text"
    t.bigint "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_maps_on_created_at"
    t.index ["creator_id"], name: "index_maps_on_creator_id"
    t.index ["privacy"], name: "index_maps_on_privacy"
  end

  create_table "places", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "address"
    t.string "place_type"
    t.string "emoji"
    t.text "context"
    t.integer "position"
    t.bigint "map_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["map_id", "position"], name: "index_places_on_map_id_and_position"
    t.index ["map_id"], name: "index_places_on_map_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.integer "maps_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.integer "role", default: 0
    t.integer "maps_limit", default: 5
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "map_tags", "maps"
  add_foreign_key "map_tags", "tags"
  add_foreign_key "maps", "users", column: "creator_id"
  add_foreign_key "places", "maps"
end
