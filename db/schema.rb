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

ActiveRecord::Schema.define(version: 20150321055605) do

  create_table "binders", force: true do |t|
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "name"
    t.integer  "store_id"
    t.integer  "products_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "oldid"
    t.integer  "sequence",       default: 100,  null: false
    t.boolean  "activated",      default: true, null: false
  end

  create_table "comments", force: true do |t|
    t.integer  "customer_id"
    t.integer  "commentable_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ancestry"
    t.string   "commentable_type"
  end

  add_index "comments", ["ancestry"], name: "index_comments_on_ancestry", using: :btree
  add_index "comments", ["customer_id", "commentable_id"], name: "index_comments_on_customer_id_and_commentable_id", using: :btree

  create_table "customer_events", force: true do |t|
    t.integer  "customer_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.string   "duration"
    t.string   "frequency"
    t.string   "event_type"
    t.integer  "event_count"
    t.string   "name"
    t.string   "url"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", force: true do |t|
    t.integer  "instance_id"
    t.integer  "status",                                     default: 0
    t.string   "openid"
    t.string   "name"
    t.string   "phone"
    t.string   "email"
    t.integer  "credit",                                     default: 0
    t.integer  "orders_count",                               default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cid"
    t.integer  "oldid"
    t.integer  "member_id"
    t.decimal  "balance",            precision: 8, scale: 2, default: 0.0
    t.integer  "operator_id"
    t.integer  "visit_count",                                default: 0
    t.datetime "current_visit_at"
    t.datetime "last_visit_at"
    t.string   "current_visit_ip"
    t.string   "last_visit_ip"
    t.boolean  "subscribed",                                 default: true
    t.string   "avatar",                                     default: "",                                   null: false
    t.string   "province",                                   default: "",                                   null: false
    t.string   "city",                                       default: "",                                   null: false
    t.string   "country",                                    default: "",                                   null: false
    t.string   "nickname",                                   default: "",                                   null: false
    t.integer  "gender",                                     default: 0,                                    null: false
    t.integer  "from_sceneid",                               default: 0,                                    null: false
    t.integer  "default_village_id"
    t.text     "intro"
    t.string   "cs_tip",                                     default: "欢迎光临！使用过程中如需任何帮助，可点击右下角客服图标，必竭诚服务！"
    t.text     "info"
  end

  add_index "customers", ["member_id", "instance_id"], name: "index_customers_on_member_id_and_instance_id", using: :btree

  create_table "express_stores", force: true do |t|
    t.integer  "store_id"
    t.integer  "express_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expresses", force: true do |t|
    t.string   "name"
    t.string   "addr"
    t.text     "desc"
    t.string   "phone"
    t.string   "invite_code"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favors", force: true do |t|
    t.integer  "customer_id"
    t.integer  "village_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favors", ["customer_id", "village_item_id"], name: "index_favors_on_customer_id_and_village_item_id", using: :btree

  create_table "forem_categories", force: true do |t|
    t.string   "name",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.integer  "position",   default: 0
  end

  add_index "forem_categories", ["slug"], name: "index_forem_categories_on_slug", unique: true, using: :btree

  create_table "forem_forums", force: true do |t|
    t.string  "name"
    t.text    "description"
    t.integer "category_id"
    t.integer "views_count", default: 0
    t.string  "slug"
    t.integer "position",    default: 0
  end

  add_index "forem_forums", ["slug"], name: "index_forem_forums_on_slug", unique: true, using: :btree

  create_table "forem_groups", force: true do |t|
    t.string "name"
  end

  add_index "forem_groups", ["name"], name: "index_forem_groups_on_name", using: :btree

  create_table "forem_memberships", force: true do |t|
    t.integer "group_id"
    t.integer "member_id"
  end

  add_index "forem_memberships", ["group_id"], name: "index_forem_memberships_on_group_id", using: :btree

  create_table "forem_moderator_groups", force: true do |t|
    t.integer "forum_id"
    t.integer "group_id"
  end

  add_index "forem_moderator_groups", ["forum_id"], name: "index_forem_moderator_groups_on_forum_id", using: :btree

  create_table "forem_posts", force: true do |t|
    t.integer  "topic_id"
    t.text     "text"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reply_to_id"
    t.string   "state",       default: "pending_review"
    t.boolean  "notified",    default: false
    t.string   "attachment"
  end

  add_index "forem_posts", ["reply_to_id"], name: "index_forem_posts_on_reply_to_id", using: :btree
  add_index "forem_posts", ["state"], name: "index_forem_posts_on_state", using: :btree
  add_index "forem_posts", ["topic_id"], name: "index_forem_posts_on_topic_id", using: :btree
  add_index "forem_posts", ["user_id"], name: "index_forem_posts_on_user_id", using: :btree

  create_table "forem_subscriptions", force: true do |t|
    t.integer "subscriber_id"
    t.integer "topic_id"
  end

  create_table "forem_topics", force: true do |t|
    t.integer  "forum_id"
    t.integer  "user_id"
    t.string   "subject"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "locked",       default: false,            null: false
    t.boolean  "pinned",       default: false
    t.boolean  "hidden",       default: false
    t.datetime "last_post_at"
    t.string   "state",        default: "pending_review"
    t.integer  "views_count",  default: 0
    t.string   "slug"
  end

  add_index "forem_topics", ["forum_id"], name: "index_forem_topics_on_forum_id", using: :btree
  add_index "forem_topics", ["slug"], name: "index_forem_topics_on_slug", unique: true, using: :btree
  add_index "forem_topics", ["state"], name: "index_forem_topics_on_state", using: :btree
  add_index "forem_topics", ["user_id"], name: "index_forem_topics_on_user_id", using: :btree

  create_table "forem_views", force: true do |t|
    t.integer  "user_id"
    t.integer  "viewable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "count",             default: 0
    t.string   "viewable_type"
    t.datetime "current_viewed_at"
    t.datetime "past_viewed_at"
  end

  add_index "forem_views", ["updated_at"], name: "index_forem_views_on_updated_at", using: :btree
  add_index "forem_views", ["user_id"], name: "index_forem_views_on_user_id", using: :btree
  add_index "forem_views", ["viewable_id"], name: "index_forem_views_on_viewable_id", using: :btree

  create_table "instances", force: true do |t|
    t.string   "name"
    t.string   "nick"
    t.text     "description"
    t.string   "phone"
    t.string   "email"
    t.string   "app_id"
    t.string   "app_secret"
    t.string   "token"
    t.integer  "creator_id"
    t.integer  "stores_count",     default: 0
    t.integer  "orders_count",     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "api_echoed",       default: 0
    t.string   "logo"
    t.float    "longitude"
    t.float    "latitude"
    t.string   "banner"
    t.string   "slogan",           default: "",    null: false
    t.string   "address",          default: ""
    t.integer  "oldid"
    t.integer  "credit",           default: 0
    t.string   "openid"
    t.string   "qrcode"
    t.integer  "customers_count",  default: 0,     null: false
    t.string   "invite_code"
    t.integer  "kategories_count", default: 0,     null: false
    t.boolean  "check_location",   default: false, null: false
    t.integer  "sceneid"
    t.string   "member_card"
    t.string   "partner_id"
    t.string   "partner_key"
    t.string   "pay_sign_key"
    t.boolean  "csa",              default: true,  null: false
    t.integer  "lottery_pick_max", default: 1
    t.string   "template_id"
    t.string   "fixed_mechat_url"
    t.string   "float_mechat_url", default: ""
  end

  create_table "kategories", force: true do |t|
    t.string   "name",         default: "",  null: false
    t.integer  "instance_id"
    t.integer  "stores_count", default: 0,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sequence",     default: 100, null: false
    t.string   "logo"
    t.string   "description"
  end

  create_table "leagueships", force: true do |t|
    t.integer  "village_id"
    t.integer  "village_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "leagueships", ["village_id"], name: "index_leagueships_on_village_id", using: :btree
  add_index "leagueships", ["village_item_id"], name: "index_leagueships_on_village_item_id", using: :btree

  create_table "license_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "license_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "licenses", force: true do |t|
    t.string   "name"
    t.integer  "max_instance",                         default: 0
    t.integer  "max_store",                            default: 0
    t.integer  "max_order",                            default: 0
    t.decimal  "price",        precision: 8, scale: 2, default: 0.0
    t.integer  "users_count",                          default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.integer  "customer_id"
    t.float    "longitude",   default: 0.0, null: false
    t.float    "latitude",    default: 0.0, null: false
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lotteries", force: true do |t|
    t.integer  "customer_id"
    t.integer  "order_id"
    t.string   "phone"
    t.string   "comm_key"
    t.integer  "game_type"
    t.integer  "issue"
    t.integer  "seq_no"
    t.integer  "amount"
    t.integer  "vote_type"
    t.integer  "multi"
    t.string   "flowid"
    t.string   "vote_nums"
    t.string   "random_unique_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lottery_type",     default: 0, null: false
    t.integer  "instance_id"
  end

  add_index "lotteries", ["instance_id", "customer_id", "order_id"], name: "index_lotteries_on_instance_id_and_customer_id_and_order_id", using: :btree

  create_table "meetups", force: true do |t|
    t.text     "comment"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", force: true do |t|
    t.string   "name"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "birthday"
    t.string   "address"
    t.integer  "instance_id"
  end

  add_index "members", ["instance_id"], name: "index_members_on_instance_id", using: :btree

  create_table "offers", force: true do |t|
    t.text     "info"
    t.string   "title"
    t.integer  "duration"
    t.integer  "village_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
  end

  add_index "offers", ["village_item_id"], name: "index_offers_on_village_item_id", using: :btree

  create_table "operations", force: true do |t|
    t.integer  "instance_id"
    t.integer  "store_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "kategory_id"
    t.integer  "sequence",    default: 1000, null: false
    t.integer  "sceneid"
  end

  create_table "options_groups", force: true do |t|
    t.integer  "wesell_item_id"
    t.integer  "style"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",           default: "", null: false
    t.integer  "oldid"
  end

  create_table "order_actions", force: true do |t|
    t.integer  "order_id"
    t.string   "action_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "actioner_type"
    t.integer  "actioner_id"
  end

  create_table "order_config_options", force: true do |t|
    t.integer  "order_config_id"
    t.integer  "store_id"
    t.string   "name"
    t.decimal  "price",           precision: 8, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_configs", force: true do |t|
    t.integer  "store_id"
    t.string   "name"
    t.integer  "style",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_item_options", force: true do |t|
    t.integer  "order_item_id"
    t.integer  "wesell_item_option_id"
    t.string   "name"
    t.decimal  "price",                 precision: 8, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_items", force: true do |t|
    t.integer  "order_id"
    t.integer  "wesell_item_id"
    t.integer  "category_id"
    t.decimal  "unit_price",     precision: 8, scale: 2, default: 0.0
    t.string   "unit_name"
    t.string   "name"
    t.integer  "quantity",                               default: 0
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "oldid"
    t.string   "option_ids"
  end

  create_table "order_options", force: true do |t|
    t.integer  "order_id"
    t.integer  "order_config_option_id"
    t.string   "name"
    t.decimal  "price",                  precision: 8, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: true do |t|
    t.integer  "store_id"
    t.integer  "instance_id"
    t.integer  "customer_id"
    t.decimal  "amount",                 precision: 8, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",                                         default: "open"
    t.string   "address"
    t.string   "contact"
    t.string   "phone"
    t.string   "comment"
    t.integer  "items_count",                                    default: 0
    t.string   "payment_option",                                 default: "",     null: false
    t.string   "payment_status",                                 default: "",     null: false
    t.integer  "oldid"
    t.datetime "submit_at"
    t.string   "description"
    t.datetime "start_at"
    t.decimal  "shipping_charge",        precision: 8, scale: 2, default: 0.0
    t.string   "oid",                                            default: "",     null: false
    t.integer  "serial_number",                                  default: 0,      null: false
    t.integer  "serial_number_instance",                         default: 0,      null: false
    t.boolean  "is_test",                                        default: false
    t.integer  "csn",                                            default: 0,      null: false
    t.integer  "csni",                                           default: 0,      null: false
    t.string   "transid",                                        default: "",     null: false
    t.integer  "express_id"
  end

  add_index "orders", ["customer_id"], name: "index_orders_on_customer_id", using: :btree
  add_index "orders", ["instance_id"], name: "index_orders_on_instance_id", using: :btree
  add_index "orders", ["store_id"], name: "index_orders_on_store_id", using: :btree

  create_table "ownerships", force: true do |t|
    t.integer  "user_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.string   "role_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pearls", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.string   "tutor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "openid"
  end

  create_table "pictures", force: true do |t|
    t.string   "pic"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "printers", force: true do |t|
    t.string   "name"
    t.string   "model"
    t.string   "imei"
    t.string   "status"
    t.integer  "copies",     default: 1, null: false
    t.integer  "store_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "oldid"
  end

  create_table "records", force: true do |t|
    t.string   "content"
    t.integer  "customer_id"
    t.integer  "instance_id"
    t.integer  "result_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "records", ["customer_id"], name: "index_records_on_customer_id", using: :btree

  create_table "replies", force: true do |t|
    t.string   "replyable_type"
    t.integer  "replyable_id"
    t.text     "hash_content"
    t.string   "status"
    t.integer  "user_id"
    t.string   "msg_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "replies", ["replyable_id"], name: "index_replies_on_replyable_id", using: :btree

  create_table "reports", force: true do |t|
    t.date     "report_date"
    t.integer  "store_id"
    t.integer  "total_orders"
    t.integer  "valid_orders"
    t.decimal  "total_income", precision: 8, scale: 2, default: 0.0
    t.integer  "item_sold"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "settings", force: true do |t|
    t.string   "var",         null: false
    t.text     "value"
    t.integer  "target_id",   null: false
    t.string   "target_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["target_type", "target_id", "var"], name: "index_settings_on_target_type_and_target_id_and_var", unique: true, using: :btree

  create_table "showrooms", force: true do |t|
    t.string   "name"
    t.integer  "store_id"
    t.integer  "max_quantity", default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "instance_id"
  end

  create_table "stores", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "phone"
    t.string   "email"
    t.string   "street"
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "creator_id"
    t.integer  "orders_count",                                   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
    t.string   "banner"
    t.string   "slogan",                                         default: "",       null: false
    t.decimal  "min_charge",             precision: 8, scale: 2, default: 0.0
    t.integer  "oldid"
    t.string   "invite_code"
    t.string   "monetary_unit"
    t.boolean  "open",                                           default: false,    null: false
    t.string   "time_setting"
    t.string   "address_setting"
    t.integer  "categories_count",                               default: 0,        null: false
    t.integer  "instances_count",                                default: 0,        null: false
    t.integer  "wesell_items_count",                             default: 0,        null: false
    t.float    "service_radius"
    t.boolean  "deleted",                                        default: false,    null: false
    t.string   "opening_hours"
    t.decimal  "shipping_charge",        precision: 8, scale: 2, default: 0.0
    t.integer  "shipping_charge_option"
    t.boolean  "require_confirm",                                default: false
    t.integer  "payment_options_mask",                           default: 1
    t.string   "link"
    t.text     "notice"
    t.text     "guide"
    t.boolean  "show_buyers",                                    default: false
    t.string   "stype",                                          default: "normal"
  end

  create_table "sub_tags", force: true do |t|
    t.integer  "tag_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "click_count", default: 0
  end

  add_index "sub_tags", ["tag_id"], name: "index_sub_tags_on_tag_id", using: :btree

  create_table "taggings", force: true do |t|
    t.integer  "sub_tag_id"
    t.integer  "village_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["sub_tag_id", "village_item_id"], name: "index_taggings_on_sub_tag_id_and_village_item_id", using: :btree

  create_table "tags", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "click_count", default: 0
  end

  create_table "user_village_items", force: true do |t|
    t.integer  "user_id"
    t.integer  "village_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",               null: false
    t.string   "encrypted_password",     default: "",               null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,                null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "role_identifier"
    t.integer  "oldid"
    t.boolean  "forem_admin",            default: false
    t.string   "forem_state",            default: "pending_review"
    t.boolean  "forem_auto_subscribe",   default: false
    t.string   "status",                 default: "trial"
    t.integer  "keeper_id"
    t.string   "phone"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "village_items", force: true do |t|
    t.integer  "village_id"
    t.string   "name"
    t.string   "tel"
    t.string   "addr"
    t.text     "info"
    t.integer  "call_count",        default: 0
    t.string   "logo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "favor_count",       default: 0
    t.integer  "store_id"
    t.string   "opening_hours"
    t.integer  "click_count",       default: 0
    t.string   "meta"
    t.integer  "vscore",            default: 0,  null: false
    t.string   "url",               default: "", null: false
    t.string   "doc"
    t.datetime "approved_start_at"
    t.datetime "approved_end_at"
    t.text     "disabled_reason"
    t.string   "pin"
    t.integer  "level",             default: 1
    t.text     "page"
    t.integer  "sceneid"
    t.integer  "instance_id"
    t.string   "remark"
    t.integer  "comments_count",    default: 0
    t.string   "banner"
    t.integer  "commenters_count",  default: 0
    t.integer  "referral_id"
    t.integer  "owner_id"
    t.string   "admin_email"
    t.string   "admin_phone"
    t.string   "admin_name"
    t.integer  "cca_id"
  end

  add_index "village_items", ["village_id"], name: "index_village_items_on_village_id", using: :btree

  create_table "villages", force: true do |t|
    t.integer  "instance_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slogan"
    t.text     "desc"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "logo"
    t.string   "banner"
    t.integer  "css_id"
  end

  add_index "villages", ["instance_id"], name: "index_villages_on_instance_id", using: :btree

  create_table "wechat_keys", force: true do |t|
    t.integer  "instance_id"
    t.string   "tips"
    t.string   "key"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "banner"
    t.string   "url"
    t.string   "msg_type"
  end

  add_index "wechat_keys", ["instance_id"], name: "index_wechat_keys_on_instance_id", using: :btree

  create_table "wechat_menus", force: true do |t|
    t.integer "instance_id"
    t.string  "menu_type"
    t.string  "name"
    t.string  "key"
    t.text    "url"
    t.integer "wechat_sub_menus_count", default: 0, null: false
    t.integer "sequence",               default: 0
  end

  create_table "wechat_sub_menus", force: true do |t|
    t.integer "wechat_menu_id"
    t.string  "menu_type"
    t.string  "name"
    t.string  "key"
    t.string  "url"
    t.integer "sequence",       default: 0
  end

  create_table "wesell_item_options", force: true do |t|
    t.integer  "wesell_item_id"
    t.string   "name"
    t.decimal  "price",            precision: 8, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted",                                  default: false, null: false
    t.integer  "options_group_id"
    t.integer  "sequence",                                 default: 10
  end

  create_table "wesell_items", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "price",                precision: 8, scale: 2, default: 0.0
    t.decimal  "original_price",       precision: 8, scale: 2, default: 0.0
    t.string   "unit_name"
    t.integer  "quantity",                                     default: 0
    t.integer  "total_sold",                                   default: 0
    t.integer  "status",                                       default: 0
    t.string   "image"
    t.integer  "store_id"
    t.integer  "category_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "oldid"
    t.string   "banner"
    t.integer  "options_groups_count",                         default: 0,      null: false
    t.integer  "sequence",                                     default: 100,    null: false
    t.boolean  "deleted",                                      default: false,  null: false
    t.text     "info"
    t.string   "rule",                                         default: "norm", null: false
    t.integer  "showroom_id"
    t.string   "remark"
    t.integer  "comments_count",                               default: 0
    t.integer  "checkin_count",                                default: 0
    t.string   "event_location"
    t.string   "event_time"
    t.string   "event_tip"
    t.text     "guide"
    t.boolean  "visitor_allowed",                              default: false
    t.boolean  "show_cinfo",                                   default: false
    t.string   "addon_hints"
  end

end
