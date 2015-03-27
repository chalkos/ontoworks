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

ActiveRecord::Schema.define(version: 20150315023746) do

  create_table "ontologies", force: :cascade do |t|
    t.string   "name",       limit: 255,                 null: false
    t.string   "code",       limit: 255,                 null: false
    t.boolean  "unlisted",               default: false, null: false
    t.boolean  "extendable",             default: false, null: false
    t.datetime "expires",                                null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "ontologies", ["code"], name: "index_ontologies_on_code", unique: true

  create_table "queries", force: :cascade do |t|
    t.string   "name",        limit: 255,     null: false
    t.text     "content",     limit: 1048576, null: false
    t.integer  "ontology_id",                 null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

end