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

ActiveRecord::Schema.define(version: 20150606190243) do

  create_table "logs", force: :cascade do |t|
    t.integer  "ontology_id"
    t.integer  "msg_type"
    t.string   "from_code",   limit: 255
    t.string   "to_code",     limit: 255
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "query_name",  limit: 255
    t.boolean  "helper"
  end

  add_index "logs", ["ontology_id"], name: "index_logs_on_ontology_id"
  add_index "logs", ["user_id"], name: "index_logs_on_user_id"

  create_table "ontologies", force: :cascade do |t|
    t.string   "name",       limit: 255,                 null: false
    t.string   "code",       limit: 255,                 null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.text     "desc"
    t.integer  "user_id"
    t.boolean  "public",                 default: false
    t.boolean  "shared",                 default: false
  end

  add_index "ontologies", ["code"], name: "index_ontologies_on_code", unique: true
  add_index "ontologies", ["user_id"], name: "index_ontologies_on_user_id"

  create_table "prefixes", force: :cascade do |t|
    t.integer "ontology_id"
    t.string  "name",        limit: 255
    t.text    "uri"
  end

  add_index "prefixes", ["ontology_id"], name: "index_prefixes_on_ontology_id"

  create_table "queries", force: :cascade do |t|
    t.string   "name",        limit: 255,     null: false
    t.text     "content",     limit: 1048576, null: false
    t.integer  "ontology_id",                 null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.text     "desc"
    t.integer  "user_id"
  end

  add_index "queries", ["user_id"], name: "index_queries_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "failed_attempts",                    default: 0,  null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                   limit: 255, default: "", null: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true

end
