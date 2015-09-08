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

ActiveRecord::Schema.define(version: 20150907195244) do

  create_table "comments", force: :cascade do |t|
    t.string   "title",            limit: 50,    default: ""
    t.text     "comment",          limit: 65535
    t.integer  "commentable_id",   limit: 4
    t.string   "commentable_type", limit: 255
    t.integer  "user_id",          limit: 4
    t.string   "role",             limit: 255,   default: "comments"
    t.string   "name",             limit: 255
    t.string   "email",            limit: 255
    t.text     "media",            limit: 65535
    t.string   "ip",               limit: 15,                         null: false
    t.string   "source_type",      limit: 10,    default: "0",        null: false
    t.string   "source",           limit: 255
    t.integer  "access",           limit: 1,     default: 0,          null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["ip"], name: "index_comments_on_ip", using: :btree
  add_index "comments", ["user_id"], name: "fk_rails_0e00f6f208", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",        limit: 100,   null: false
    t.string   "slug",        limit: 100,   null: false
    t.text     "description", limit: 65535
    t.integer  "type",        limit: 1
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "groups", ["name"], name: "index_groups_on_name", using: :btree
  add_index "groups", ["slug"], name: "index_groups_on_slug", using: :btree

  create_table "local_files", force: :cascade do |t|
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "file_file_name",    limit: 255
    t.string   "file_content_type", limit: 255
    t.integer  "file_file_size",    limit: 4
    t.datetime "file_updated_at"
    t.string   "file_fingerprint",  limit: 255
  end

  create_table "media_files", force: :cascade do |t|
    t.string   "slug",              limit: 255,   default: "", null: false
    t.integer  "resource_id",       limit: 4
    t.text     "title",             limit: 65535,              null: false
    t.integer  "copyright_license", limit: 1,     default: 0,  null: false
    t.string   "copyright_notes",   limit: 255,                null: false
    t.integer  "access",            limit: 1,     default: 0,  null: false
    t.integer  "lock_version",      limit: 4,     default: 0,  null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "sourceable_id",     limit: 4
    t.string   "sourceable_type",   limit: 255
  end

  add_index "media_files", ["resource_id"], name: "fk_rails_0031d48384", using: :btree
  add_index "media_files", ["slug"], name: "index_media_files_on_slug", using: :btree
  add_index "media_files", ["sourceable_type", "sourceable_id"], name: "index_media_files_on_sourceable_type_and_sourceable_id", using: :btree

  create_table "related_resources", force: :cascade do |t|
    t.text     "caption",          limit: 65535, null: false
    t.integer  "from_resource_id", limit: 4,     null: false
    t.integer  "to_resource_id",   limit: 4,     null: false
    t.integer  "type",             limit: 1,     null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "related_resources", ["to_resource_id"], name: "fk_rails_12fd3759e5", using: :btree

  create_table "resources", force: :cascade do |t|
    t.string   "slug",                    limit: 255,               null: false
    t.integer  "user_id",                 limit: 4,                 null: false
    t.integer  "parent_id",               limit: 4
    t.integer  "resource_type",           limit: 1,                 null: false
    t.text     "title",                   limit: 65535,             null: false
    t.text     "subtitle",                limit: 65535,             null: false
    t.string   "source_type",             limit: 10
    t.string   "source",                  limit: 255
    t.integer  "copyright_license",       limit: 1,     default: 0, null: false
    t.string   "copyright_notes",         limit: 255,               null: false
    t.integer  "rank",                    limit: 4,     default: 0, null: false
    t.integer  "access",                  limit: 1,     default: 0, null: false
    t.integer  "forked_from_resource_id", limit: 4
    t.integer  "transition",              limit: 1,     default: 0, null: false
    t.integer  "lock_version",            limit: 4,     default: 0, null: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "resources", ["forked_from_resource_id"], name: "fk_rails_3149540938", using: :btree
  add_index "resources", ["parent_id"], name: "fk_rails_fc9385137c", using: :btree
  add_index "resources", ["resource_type"], name: "index_resources_on_resource_type", using: :btree
  add_index "resources", ["slug"], name: "index_resources_on_slug", using: :btree
  add_index "resources", ["user_id"], name: "fk_rails_795c101243", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "var",         limit: 255,   null: false
    t.text     "value",       limit: 65535
    t.integer  "target_id",   limit: 4,     null: false
    t.string   "target_type", limit: 255,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["target_type", "target_id", "var"], name: "index_settings_on_target_type_and_target_id_and_var", unique: true, using: :btree

  create_table "tags", force: :cascade do |t|
    t.integer  "taggable_id",   limit: 4,                 null: false
    t.string   "taggable_type", limit: 255,               null: false
    t.integer  "tag_type",      limit: 1,   default: 0,   null: false
    t.string   "tag",           limit: 255,               null: false
    t.string   "tag_sort",      limit: 255,               null: false
    t.integer  "user_id",       limit: 4
    t.string   "ip",            limit: 15,                null: false
    t.string   "source_type",   limit: 10,  default: "0", null: false
    t.string   "source",        limit: 255
    t.integer  "access",        limit: 1,   default: 0,   null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "tags", ["ip"], name: "index_tags_on_ip", using: :btree
  add_index "tags", ["tag", "tag_type", "user_id", "taggable_id", "taggable_type"], name: "unique_tags_per_user", unique: true, using: :btree
  add_index "tags", ["tag"], name: "index_tags_on_tag", using: :btree
  add_index "tags", ["tag_sort"], name: "index_tags_on_tag_sort", using: :btree
  add_index "tags", ["tag_type"], name: "index_tags_on_tag_type", using: :btree
  add_index "tags", ["taggable_id"], name: "index_tags_on_taggable_id", using: :btree
  add_index "tags", ["taggable_type"], name: "index_tags_on_taggable_type", using: :btree
  add_index "tags", ["user_id"], name: "fk_rails_5707e0621c", using: :btree

  create_table "user_groups", force: :cascade do |t|
    t.integer  "type",       limit: 1
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "user_id",    limit: 4
    t.integer  "group_id",   limit: 4
  end

  add_index "user_groups", ["group_id"], name: "fk_rails_dc53b2596b", using: :btree
  add_index "user_groups", ["user_id"], name: "fk_rails_bd9940c1e1", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name",             limit: 255,              null: false
    t.string   "last_name",              limit: 255,              null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255,        null: false
    t.integer  "item_id",    limit: 4,          null: false
    t.string   "event",      limit: 255,        null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object",     limit: 4294967295
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "youtube_links", force: :cascade do |t|
    t.string   "key",           limit: 16,  null: false
    t.string   "original_link", limit: 255, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "youtube_links", ["key"], name: "index_youtube_links_on_key", using: :btree

  add_foreign_key "comments", "users"
  add_foreign_key "media_files", "resources"
  add_foreign_key "related_resources", "resources", column: "to_resource_id"
  add_foreign_key "resources", "resources", column: "forked_from_resource_id"
  add_foreign_key "resources", "resources", column: "parent_id"
  add_foreign_key "resources", "users"
  add_foreign_key "tags", "users"
  add_foreign_key "user_groups", "groups"
  add_foreign_key "user_groups", "users"
end
