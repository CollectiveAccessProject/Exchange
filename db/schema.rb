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

ActiveRecord::Schema.define(version: 20180103031240) do

  create_table "average_caches", force: :cascade do |t|
    t.integer  "rater_id",      limit: 4
    t.integer  "rateable_id",   limit: 4
    t.string   "rateable_type", limit: 255
    t.float    "avg",           limit: 24,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collectionobject_links", force: :cascade do |t|
    t.integer  "resource_id",   limit: 4,   null: false
    t.string   "original_link", limit: 255, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "collectionobject_links", ["resource_id"], name: "index_collectionobject_links_on_resource_id", using: :btree

  create_table "collectiveaccess_links", force: :cascade do |t|
    t.string   "host",          limit: 255, null: false
    t.string   "key",           limit: 50,  null: false
    t.string   "base_url",      limit: 255, null: false
    t.string   "original_link", limit: 255, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "collectiveaccess_links", ["base_url"], name: "index_collectiveaccess_links_on_base_url", using: :btree
  add_index "collectiveaccess_links", ["host"], name: "index_collectiveaccess_links_on_host", using: :btree
  add_index "collectiveaccess_links", ["key"], name: "index_collectiveaccess_links_on_key", using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "title",            limit: 50,       default: ""
    t.text     "comment",          limit: 16777215
    t.integer  "commentable_id",   limit: 4
    t.string   "commentable_type", limit: 255
    t.integer  "user_id",          limit: 4
    t.string   "role",             limit: 255,      default: "comments"
    t.string   "name",             limit: 255
    t.string   "email",            limit: 255
    t.text     "media",            limit: 16777215
    t.string   "ip",               limit: 15,                            null: false
    t.string   "source_type",      limit: 10,       default: "0",        null: false
    t.string   "source",           limit: 255
    t.integer  "access",           limit: 1,        default: 0,          null: false
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["ip"], name: "index_comments_on_ip", using: :btree
  add_index "comments", ["user_id"], name: "fk_rails_adbfa98bd4", using: :btree

  create_table "favorites", force: :cascade do |t|
    t.integer  "resource_id", limit: 4, null: false
    t.integer  "user_id",     limit: 4, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "favorites", ["resource_id"], name: "index_favorites_on_resource_id", using: :btree
  add_index "favorites", ["user_id"], name: "index_favorites_on_user_id", using: :btree

  create_table "featured_content_set_items", force: :cascade do |t|
    t.text     "title",                   limit: 65535,             null: false
    t.text     "subtitle",                limit: 65535,             null: false
    t.integer  "featured_content_set_id", limit: 4,                 null: false
    t.integer  "resource_id",             limit: 4,                 null: false
    t.integer  "rank",                    limit: 4,     default: 0, null: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "featured_content_set_items", ["featured_content_set_id"], name: "index_featured_content_set_items_on_featured_content_set_id", using: :btree
  add_index "featured_content_set_items", ["resource_id"], name: "index_featured_content_set_items_on_resource_id", using: :btree

  create_table "featured_content_sets", force: :cascade do |t|
    t.text     "title",      limit: 65535,             null: false
    t.text     "subtitle",   limit: 65535,             null: false
    t.text     "body_text",  limit: 65535,             null: false
    t.string   "slug",       limit: 255,               null: false
    t.integer  "user_id",    limit: 4
    t.integer  "rank",       limit: 4,     default: 0, null: false
    t.integer  "access",     limit: 1,     default: 0, null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "featured_content_sets", ["slug"], name: "index_featured_content_sets_on_slug", using: :btree
  add_index "featured_content_sets", ["user_id"], name: "index_featured_content_sets_on_user_id", using: :btree

  create_table "flickr_links", force: :cascade do |t|
    t.integer  "photo_id",      limit: 8,   null: false
    t.string   "original_link", limit: 255, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "flickr_links", ["photo_id"], name: "index_flickr_links_on_photo_id", using: :btree

  create_table "googledocs_links", force: :cascade do |t|
    t.string   "original_link", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name",        limit: 100,      null: false
    t.string   "slug",        limit: 100,      null: false
    t.text     "description", limit: 16777215
    t.integer  "group_type",  limit: 1
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "user_id",     limit: 4
    t.string   "group_code",  limit: 255
  end

  add_index "groups", ["name"], name: "index_groups_on_name", using: :btree
  add_index "groups", ["slug"], name: "index_groups_on_slug", using: :btree

  create_table "indices", force: :cascade do |t|
  end

  create_table "links", force: :cascade do |t|
    t.integer  "resource_id", limit: 4,     null: false
    t.text     "caption",     limit: 65535, null: false
    t.string   "url",         limit: 1024,  null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "rank",        limit: 4
  end

  create_table "local_files", force: :cascade do |t|
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "file_file_name",    limit: 255
    t.string   "file_content_type", limit: 255
    t.integer  "file_file_size",    limit: 4
    t.datetime "file_updated_at"
    t.string   "file_fingerprint",  limit: 255
    t.string   "url",               limit: 255
  end

  create_table "media_files", force: :cascade do |t|
    t.string   "slug",                          limit: 255,      default: "", null: false
    t.integer  "resource_id",                   limit: 4
    t.text     "caption",                       limit: 16777215,              null: false
    t.integer  "copyright_license",             limit: 1,        default: 0,  null: false
    t.string   "copyright_notes",               limit: 255,                   null: false
    t.integer  "access",                        limit: 1,        default: 0,  null: false
    t.integer  "lock_version",                  limit: 4,        default: 0,  null: false
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.integer  "sourceable_id",                 limit: 4
    t.string   "sourceable_type",               limit: 255
    t.integer  "rank",                          limit: 4
    t.string   "thumbnail_uid",                 limit: 255
    t.string   "title",                         limit: 255
    t.integer  "caption_type",                  limit: 4
    t.integer  "display_collectionobject_link", limit: 2
    t.string   "alt_text",                      limit: 4096,     default: "", null: false
  end

  add_index "media_files", ["resource_id"], name: "fk_rails_0b5d71f8d5", using: :btree
  add_index "media_files", ["slug"], name: "index_media_files_on_slug", using: :btree
  add_index "media_files", ["sourceable_type", "sourceable_id"], name: "index_media_files_on_sourceable_type_and_sourceable_id", using: :btree

  create_table "overall_averages", force: :cascade do |t|
    t.integer  "rateable_id",   limit: 4
    t.string   "rateable_type", limit: 255
    t.float    "overall_avg",   limit: 24,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rates", force: :cascade do |t|
    t.integer  "rater_id",      limit: 4
    t.integer  "rateable_id",   limit: 4
    t.string   "rateable_type", limit: 255
    t.float    "stars",         limit: 24,  null: false
    t.string   "dimension",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rates", ["rateable_id", "rateable_type"], name: "index_rates_on_rateable_id_and_rateable_type", using: :btree
  add_index "rates", ["rater_id"], name: "index_rates_on_rater_id", using: :btree

  create_table "rating_caches", force: :cascade do |t|
    t.integer  "cacheable_id",   limit: 4
    t.string   "cacheable_type", limit: 255
    t.float    "avg",            limit: 24,  null: false
    t.integer  "qty",            limit: 4,   null: false
    t.string   "dimension",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rating_caches", ["cacheable_id", "cacheable_type"], name: "index_rating_caches_on_cacheable_id_and_cacheable_type", using: :btree

  create_table "related_resources", force: :cascade do |t|
    t.text     "caption",        limit: 16777215, null: false
    t.integer  "resource_id",    limit: 4,        null: false
    t.integer  "to_resource_id", limit: 4,        null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "rank",           limit: 4
  end

  add_index "related_resources", ["resource_id"], name: "fk_rails_e3bdcff243", using: :btree
  add_index "related_resources", ["to_resource_id"], name: "fk_rails_2eadc87d49", using: :btree

  create_table "resource_hierarchies", force: :cascade do |t|
    t.integer  "resource_id",       limit: 4, null: false
    t.integer  "child_resource_id", limit: 4, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "rank",              limit: 4
  end

  add_index "resource_hierarchies", ["child_resource_id"], name: "fk_rails_61957bcd1b", using: :btree
  add_index "resource_hierarchies", ["resource_id"], name: "fk_rails_0a6edc9d17", using: :btree

  create_table "resource_parents", force: :cascade do |t|
    t.integer  "parent_resource_id", limit: 4, null: false
    t.integer  "child_resource_id",  limit: 4, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "resources", force: :cascade do |t|
    t.string   "slug",                       limit: 255,                                                  null: false
    t.integer  "user_id",                    limit: 4,                                                    null: false
    t.integer  "resource_type",              limit: 1,                                                    null: false
    t.text     "title",                      limit: 16777215,                                             null: false
    t.text     "subtitle",                   limit: 16777215,                                             null: false
    t.string   "source_type",                limit: 10
    t.string   "source",                     limit: 255
    t.integer  "copyright_license",          limit: 1,                                    default: 0,     null: false
    t.text     "copyright_notes",            limit: 4294967295,                                           null: false
    t.integer  "access",                     limit: 1,                                    default: 0,     null: false
    t.integer  "forked_from_resource_id",    limit: 4
    t.integer  "transition",                 limit: 1,                                    default: 0,     null: false
    t.integer  "lock_version",               limit: 4,                                    default: 0,     null: false
    t.datetime "created_at",                                                                              null: false
    t.datetime "updated_at",                                                                              null: false
    t.text     "body_text",                  limit: 4294967295
    t.string   "collectiveaccess_id",        limit: 255,                                  default: ""
    t.text     "indexing_data",              limit: 16777215
    t.string   "author_name",                limit: 255
    t.string   "collection_identifier",      limit: 255
    t.string   "role",                       limit: 1024
    t.integer  "author_id",                  limit: 4
    t.integer  "in_response_to_resource_id", limit: 4
    t.integer  "average_rating",             limit: 4,                                    default: 0
    t.integer  "response_banned_on",         limit: 4
    t.text     "response_ban_reason",        limit: 65535
    t.text     "title_sort",                 limit: 65535,                                                null: false
    t.datetime "date_of_visit"
    t.boolean  "on_display",                                                              default: false
    t.string   "location",                   limit: 255,                                  default: ""
    t.string   "artist",                     limit: 1024,                                 default: "",    null: false
    t.decimal  "start_date",                                    precision: 40, scale: 20
    t.decimal  "end_date",                                      precision: 40, scale: 20
    t.string   "classification",             limit: 255,                                  default: "",    null: false
    t.string   "additional_classification",  limit: 255,                                  default: "",    null: false
    t.string   "medium",                     limit: 255,                                  default: "",    null: false
    t.string   "support",                    limit: 255,                                  default: "",    null: false
    t.string   "style",                      limit: 255,                                  default: "",    null: false
    t.string   "artist_nationality",         limit: 255,                                  default: "",    null: false
    t.integer  "crc_sync_date",              limit: 4
    t.integer  "crc_set_id",                 limit: 4
    t.string   "collection_area",            limit: 1024,                                 default: "",    null: false
    t.text     "subject_matter",             limit: 65535
    t.text     "label_copy",                 limit: 65535
    t.text     "keywords",                   limit: 65535
    t.string   "gallery_url",                limit: 1024,                                 default: "",    null: false
  end

  add_index "resources", ["forked_from_resource_id"], name: "fk_rails_8c3d1e0d9a", using: :btree
  add_index "resources", ["resource_type"], name: "index_resources_on_resource_type", using: :btree
  add_index "resources", ["slug"], name: "index_resources_on_slug", using: :btree
  add_index "resources", ["user_id"], name: "fk_rails_ba0e3c0a94", using: :btree

  create_table "resources_groups", force: :cascade do |t|
    t.integer "resource_id", limit: 4
    t.integer "group_id",    limit: 4
    t.integer "access",      limit: 1
  end

  create_table "resources_roles", id: false, force: :cascade do |t|
    t.integer "resource_id", limit: 4
    t.integer "role_id",     limit: 4
  end

  add_index "resources_roles", ["resource_id", "role_id"], name: "index_resources_roles_on_resource_id_and_role_id", using: :btree

  create_table "resources_users", force: :cascade do |t|
    t.integer "resource_id", limit: 4
    t.integer "user_id",     limit: 4
    t.integer "access",      limit: 1
  end

  create_table "resources_vocabulary_terms", force: :cascade do |t|
    t.integer  "resource_id",        limit: 4,  null: false
    t.integer  "vocabulary_term_id", limit: 4,  null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "user_id",            limit: 4
    t.string   "ip",                 limit: 15, null: false
  end

  add_index "resources_vocabulary_terms", ["resource_id"], name: "index_resources_vocabulary_terms_on_resource_id", using: :btree
  add_index "resources_vocabulary_terms", ["user_id"], name: "index_resources_vocabulary_terms_on_user_id", using: :btree
  add_index "resources_vocabulary_terms", ["vocabulary_term_id"], name: "index_resources_vocabulary_terms_on_vocabulary_term_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id",   limit: 4
    t.string   "resource_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "var",         limit: 255,      null: false
    t.text     "value",       limit: 16777215
    t.integer  "target_id",   limit: 4,        null: false
    t.string   "target_type", limit: 255,      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["target_type", "target_id", "var"], name: "index_settings_on_target_type_and_target_id_and_var", unique: true, using: :btree

  create_table "soundcloud_links", force: :cascade do |t|
    t.string   "original_link", limit: 255, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "soundcloud_links", ["original_link"], name: "index_soundcloud_links_on_original_link", using: :btree

  create_table "sync_logs", force: :cascade do |t|
    t.integer  "num_deleted", limit: 4, default: 0, null: false
    t.integer  "num_updated", limit: 4, default: 0, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

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
  add_index "tags", ["user_id"], name: "fk_rails_3a148b8bf5", using: :btree

  create_table "user_groups", force: :cascade do |t|
    t.integer  "access_type", limit: 1
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "user_id",     limit: 4
    t.integer  "group_id",    limit: 4
  end

  add_index "user_groups", ["group_id"], name: "fk_rails_d51d929145", using: :btree
  add_index "user_groups", ["user_id"], name: "fk_rails_37508c3355", using: :btree

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
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.string   "name",                   limit: 255,              null: false
    t.boolean  "is_admin"
    t.integer  "is_disabled",            limit: 1,   default: 0,  null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["provider"], name: "index_users_on_provider", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "role_id", limit: 4
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255,        null: false
    t.integer  "item_id",    limit: 4,          null: false
    t.string   "event",      limit: 255,        null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object",     limit: 4294967295
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "vimeo_links", force: :cascade do |t|
    t.string   "key",           limit: 16,  null: false
    t.string   "original_link", limit: 255, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "vimeo_links", ["key"], name: "index_vimeo_links_on_key", using: :btree

  create_table "vocabulary_term_synonyms", force: :cascade do |t|
    t.string   "synonym",            limit: 255,               null: false
    t.integer  "vocabulary_term_id", limit: 4,                 null: false
    t.text     "description",        limit: 65535,             null: false
    t.string   "reference_url",      limit: 255,               null: false
    t.integer  "lock_version",       limit: 4,     default: 0, null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "vocabulary_term_synonyms", ["vocabulary_term_id"], name: "index_vocabulary_term_synonyms_on_vocabulary_term_id", using: :btree

  create_table "vocabulary_terms", force: :cascade do |t|
    t.string   "term",          limit: 255,               null: false
    t.text     "description",   limit: 65535,             null: false
    t.string   "reference_url", limit: 255,               null: false
    t.integer  "lock_version",  limit: 4,     default: 0, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "ancestry",      limit: 255
  end

  add_index "vocabulary_terms", ["ancestry"], name: "index_vocabulary_terms_on_ancestry", using: :btree

  create_table "youtube_links", force: :cascade do |t|
    t.string   "key",           limit: 16,  null: false
    t.string   "original_link", limit: 255, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "youtube_links", ["key"], name: "index_youtube_links_on_key", using: :btree

  add_foreign_key "comments", "users"
  add_foreign_key "featured_content_set_items", "featured_content_sets"
  add_foreign_key "media_files", "resources"
  add_foreign_key "related_resources", "resources"
  add_foreign_key "related_resources", "resources", column: "to_resource_id"
  add_foreign_key "resource_hierarchies", "resources"
  add_foreign_key "resource_hierarchies", "resources", column: "child_resource_id"
  add_foreign_key "resources", "resources", column: "forked_from_resource_id"
  add_foreign_key "resources", "users"
  add_foreign_key "tags", "users"
  add_foreign_key "user_groups", "groups"
  add_foreign_key "user_groups", "users"
end
