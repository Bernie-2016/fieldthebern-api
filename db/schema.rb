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

ActiveRecord::Schema.define(version: 20151118100746) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "address_updates", force: :cascade do |t|
    t.integer  "address_id"
    t.integer  "visit_id"
    t.string   "update_type",                     default: "created"
    t.float    "old_latitude"
    t.float    "old_longitude"
    t.string   "old_street_1"
    t.string   "old_street_2"
    t.string   "old_city"
    t.string   "old_state_code"
    t.string   "old_zip_code"
    t.datetime "old_visited_at"
    t.integer  "old_most_supportive_resident_id"
    t.string   "old_best_canvass_response"
    t.float    "new_latitude"
    t.float    "new_longitude"
    t.string   "new_street_1"
    t.string   "new_street_2"
    t.string   "new_city"
    t.string   "new_state_code"
    t.string   "new_zip_code"
    t.datetime "new_visited_at"
    t.integer  "new_most_supportive_resident_id"
    t.string   "new_best_canvass_response"
  end

  create_table "addresses", force: :cascade do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.string   "street_1"
    t.string   "street_2"
    t.string   "city"
    t.string   "state_code"
    t.string   "zip_code"
    t.datetime "visited_at"
    t.integer  "most_supportive_resident_id"
    t.string   "usps_verified_street_1"
    t.string   "usps_verified_street_2"
    t.string   "usps_verified_city"
    t.string   "usps_verified_state"
    t.string   "usps_verified_zip"
    t.string   "best_canvass_response",       default: "not_yet_visited"
    t.string   "last_canvass_response",       default: "unknown"
  end

  create_table "devices", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token"
    t.boolean  "enabled"
    t.string   "platform"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "devices", ["token"], name: "index_devices_on_token", unique: true, using: :btree
  add_index "devices", ["user_id"], name: "index_devices_on_user_id", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "people", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "canvass_response",                             default: "unknown"
    t.string   "party_affiliation",                            default: "Unknown"
    t.integer  "address_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "phone"
    t.string   "preferred_contact_method"
    t.boolean  "previously_participated_in_caucus_or_primary", default: false
  end

  create_table "person_updates", force: :cascade do |t|
    t.integer "person_id"
    t.integer "visit_id"
    t.string  "update_type",                                      default: "created"
    t.string  "old_canvass_response"
    t.string  "new_canvass_response"
    t.string  "old_party_affiliation"
    t.string  "new_party_affiliation"
    t.string  "new_first_name"
    t.string  "old_first_name"
    t.string  "old_last_name"
    t.string  "new_last_name"
    t.integer "old_address_id"
    t.integer "new_address_id"
    t.string  "old_email"
    t.string  "new_email"
    t.string  "old_phone"
    t.string  "new_phone"
    t.string  "old_preferred_contact_method"
    t.string  "new_preferred_contact_method"
    t.boolean "old_previously_participated_in_caucus_or_primary"
    t.boolean "new_previously_participated_in_caucus_or_primary"
  end

  create_table "relationships", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "relationships", ["followed_id"], name: "index_relationships_on_followed_id", using: :btree
  add_index "relationships", ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true, using: :btree
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id", using: :btree

  create_table "scores", force: :cascade do |t|
    t.integer "points_for_updates", default: 0
    t.integer "points_for_knock",   default: 0
    t.integer "visit_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "encrypted_password",    limit: 128
    t.string   "confirmation_token",    limit: 128
    t.string   "remember_token",        limit: 128
    t.string   "facebook_id"
    t.text     "facebook_access_token"
    t.string   "home_state"
    t.integer  "total_points",                                               default: 0
    t.string   "state_code"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.integer  "visits_count",                                               default: 0
    t.text     "base_64_photo_data"
    t.decimal  "lat",                               precision: 10, scale: 6
    t.decimal  "lng",                               precision: 10, scale: 6
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["facebook_id"], name: "index_users_on_facebook_id", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

  create_table "visits", force: :cascade do |t|
    t.float    "total_points"
    t.integer  "duration_sec"
    t.integer  "user_id",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "devices", "users"
end
