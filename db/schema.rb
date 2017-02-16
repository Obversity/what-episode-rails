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

ActiveRecord::Schema.define(version: 20170215123306) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "episodes", force: :cascade do |t|
    t.integer  "number"
    t.string   "title"
    t.date     "released"
    t.string   "imdb_id"
    t.float    "imdb_rating"
    t.integer  "season_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["imdb_id"], name: "index_episodes_on_imdb_id", unique: true, using: :btree
    t.index ["season_id"], name: "index_episodes_on_season_id", using: :btree
  end

  create_table "questions", force: :cascade do |t|
    t.integer  "episode_id"
    t.string   "event"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "flag_count"
    t.index ["episode_id"], name: "index_questions_on_episode_id", using: :btree
  end

  create_table "seasons", force: :cascade do |t|
    t.integer  "number"
    t.integer  "show_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["show_id"], name: "index_seasons_on_show_id", using: :btree
  end

  create_table "shows", force: :cascade do |t|
    t.string   "title"
    t.string   "year"
    t.string   "image"
    t.string   "genre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "imdb_id"
    t.index ["imdb_id"], name: "index_shows_on_imdb_id", unique: true, using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "password"
    t.string   "salt"
    t.string   "username"
    t.string   "email"
    t.string   "token"
    t.datetime "last_signed_in"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_foreign_key "questions", "episodes"
end
