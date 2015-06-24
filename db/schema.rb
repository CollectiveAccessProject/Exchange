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

ActiveRecord::Schema.define(version: 20150624142837) do

  create_table "change_logs", force: :cascade do |t|
    t.integer  "change_log_id",   limit: 4,     null: false
    t.string   "change_log_type", limit: 255,   null: false
    t.string   "field_name",      limit: 100
    t.string   "event",           limit: 4,     null: false
    t.text     "value",           limit: 65535, null: false
    t.integer  "users_id",        limit: 4,     null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "change_logs", ["change_log_id"], name: "index_change_logs_on_change_log_id", using: :btree
  add_index "change_logs", ["change_log_type"], name: "index_change_logs_on_change_log_type", using: :btree
  add_index "change_logs", ["field_name"], name: "index_change_logs_on_field_name", using: :btree
  add_index "change_logs", ["users_id"], name: "index_change_logs_on_users_id", using: :btree

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
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "media_files", force: :cascade do |t|
    t.string   "slug",               limit: 255,   default: "", null: false
    t.integer  "resource_id",        limit: 4
    t.text     "title",              limit: 65535,              null: false
    t.string   "source_type",        limit: 10,                 null: false
    t.string   "source",             limit: 255
    t.string   "mimetype",           limit: 100
    t.integer  "copyright_license",  limit: 1,     default: 0,  null: false
    t.string   "copyright_notes",    limit: 255,                null: false
    t.integer  "access",             limit: 1,     default: 0,  null: false
    t.integer  "lock_version",       limit: 4,     default: 0,  null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "media_file_name",    limit: 255
    t.string   "media_content_type", limit: 255
    t.integer  "media_file_size",    limit: 4
    t.datetime "media_updated_at"
    t.string   "media_fingerprint",  limit: 255
  end

  add_index "media_files", ["slug"], name: "index_media_files_on_slug", using: :btree

  create_table "related_resources", force: :cascade do |t|
    t.text     "caption",          limit: 65535, null: false
    t.integer  "from_resource_id", limit: 4,     null: false
    t.integer  "to_resource_id",   limit: 4,     null: false
    t.integer  "type",             limit: 1,     null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "resources", force: :cascade do |t|
    t.string   "slug",                    limit: 255,   default: "", null: false
    t.integer  "user_id",                 limit: 4,                  null: false
    t.integer  "parent_id",               limit: 4
    t.integer  "resource_type",           limit: 1,                  null: false
    t.text     "title",                   limit: 65535,              null: false
    t.text     "subtitle",                limit: 65535,              null: false
    t.string   "source_type",             limit: 10,                 null: false
    t.string   "source",                  limit: 255
    t.integer  "copyright_license",       limit: 1,     default: 0,  null: false
    t.string   "copyright_notes",         limit: 255,                null: false
    t.integer  "rank",                    limit: 4,     default: 0,  null: false
    t.integer  "access",                  limit: 1,     default: 0,  null: false
    t.integer  "forked_from_resource_id", limit: 4
    t.integer  "transition",              limit: 1,     default: 0,  null: false
    t.integer  "lock_version",            limit: 4,     default: 0,  null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "resources", ["forked_from_resource_id"], name: "index_resources_on_forked_from_resource_id", using: :btree
  add_index "resources", ["parent_id"], name: "index_resources_on_parent_id", using: :btree
  add_index "resources", ["resource_type"], name: "index_resources_on_resource_type", using: :btree
  add_index "resources", ["slug"], name: "index_resources_on_slug", using: :btree
  add_index "resources", ["user_id"], name: "index_resources_on_user_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.integer  "taggable_id",   limit: 4,               null: false
    t.string   "taggable_type", limit: 255,             null: false
    t.integer  "type",          limit: 1,               null: false
    t.string   "tag",           limit: 255,             null: false
    t.string   "tag_sort",      limit: 255,             null: false
    t.integer  "users_id",      limit: 4,               null: false
    t.string   "ip",            limit: 15,              null: false
    t.string   "source_type",   limit: 10,              null: false
    t.string   "source",        limit: 255
    t.integer  "access",        limit: 1,   default: 0, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "tags", ["ip"], name: "index_tags_on_ip", using: :btree
  add_index "tags", ["tag"], name: "index_tags_on_tag", using: :btree
  add_index "tags", ["tag_sort"], name: "index_tags_on_tag_sort", using: :btree
  add_index "tags", ["taggable_id"], name: "index_tags_on_taggable_id", using: :btree
  add_index "tags", ["taggable_type"], name: "index_tags_on_taggable_type", using: :btree
  add_index "tags", ["type"], name: "index_tags_on_type", using: :btree
  add_index "tags", ["users_id"], name: "index_tags_on_users_id", using: :btree

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

end
