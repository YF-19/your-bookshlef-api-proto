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

ActiveRecord::Schema.define(version: 20180711013729) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "isbn", limit: 13, null: false
    t.string "title", null: false
    t.string "subtitle"
    t.string "authors"
    t.string "publisher"
    t.string "published_date"
    t.text "description"
    t.integer "page_count"
    t.string "thumbnail_url"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["isbn"], name: "index_books_on_isbn", unique: true
  end

  create_table "bookshelves", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bookshelves_on_user_id", unique: true
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "book_id", null: false
    t.integer "rating", default: 0
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "book_id"], name: "index_reviews_on_user_id_and_book_id", unique: true
  end

  create_table "stored_books", force: :cascade do |t|
    t.bigint "bookshelf_id", null: false
    t.bigint "book_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bookshelf_id", "book_id"], name: "index_stored_books_on_bookshelf_id_and_book_id", unique: true
  end

  create_table "user_relationships", force: :cascade do |t|
    t.bigint "follower_id", null: false
    t.bigint "followed_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_id"], name: "index_user_relationships_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_user_relationships_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_user_relationships_on_follower_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "remember_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "bookshelves", "users"
  add_foreign_key "reviews", "books"
  add_foreign_key "reviews", "users"
  add_foreign_key "stored_books", "books"
  add_foreign_key "stored_books", "bookshelves"
  add_foreign_key "user_relationships", "users", column: "followed_id"
  add_foreign_key "user_relationships", "users", column: "follower_id"
end
