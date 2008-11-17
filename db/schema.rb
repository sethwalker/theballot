# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20081117043902) do

  create_table "assets", :force => true do |t|
    t.string "type"
    t.string "content_type"
    t.string "filename"
    t.string "path"
  end

  create_table "assets_themes", :id => false, :force => true do |t|
    t.integer "asset_id"
    t.integer "theme_id"
  end

  add_index "assets_themes", ["asset_id"], :name => "index_on_asset_id"
  add_index "assets_themes", ["theme_id"], :name => "index_on_theme_id"

  create_table "attachments", :force => true do |t|
    t.string  "content_type"
    t.string  "filename"
    t.integer "size"
    t.integer "parent_id"
    t.string  "thumbnail"
    t.integer "width"
    t.integer "height"
    t.string  "type"
    t.integer "guide_id"
    t.integer "user_id"
    t.integer "theme_id"
  end

  add_index "attachments", ["parent_id"], :name => "index_on_parent_id"
  add_index "attachments", ["guide_id"], :name => "index_on_guide_id"
  add_index "attachments", ["user_id"], :name => "index_on_user_id"
  add_index "attachments", ["theme_id"], :name => "index_on_theme_id"

  create_table "choices", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "selection"
    t.integer  "contest_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "choices", ["contest_id"], :name => "index_on_contest_id"

  create_table "comments", :force => true do |t|
    t.string   "subject"
    t.text     "body"
    t.integer  "user_id"
    t.integer  "guide_id"
    t.datetime "created_at"
  end

  add_index "comments", ["guide_id"], :name => "index_comments_on_guide_id"
  add_index "comments", ["created_at"], :name => "index_comments_on_created_at"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "contests", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "type"
    t.integer  "guide_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contests", ["guide_id"], :name => "index_on_guide_id"

  create_table "endorsements", :force => true do |t|
    t.integer "guide_id"
    t.string  "contest"
    t.string  "candidate"
    t.text    "description"
    t.integer "position"
    t.string  "selection"
  end

  add_index "endorsements", ["guide_id"], :name => "index_on_guide_id"

  create_table "guides", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "city"
    t.string   "state"
    t.date     "date"
    t.integer  "user_id"
    t.integer  "theme_id"
    t.string   "permalink"
    t.string   "status"
    t.boolean  "endorsed"
    t.string   "legal"
    t.datetime "approved_at"
    t.integer  "approved_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "num_members"
  end

  add_index "guides", ["user_id"], :name => "index_on_user_id"
  add_index "guides", ["theme_id"], :name => "index_on_theme_id"
  add_index "guides", ["status", "approved_at", "legal"], :name => "index_on_stat_approv_legal"

  create_table "links", :force => true do |t|
    t.string  "url"
    t.text    "description"
    t.integer "guide_id"
  end

  add_index "links", ["guide_id"], :name => "index_on_guide_id"

  create_table "pledges", :force => true do |t|
    t.integer "user_id"
    t.integer "guide_id"
  end

  add_index "pledges", ["user_id"], :name => "index_on_user_id"
  add_index "pledges", ["guide_id"], :name => "index_on_guide_id"

  create_table "resources", :force => true do |t|
    t.string  "content_type"
    t.string  "filename"
    t.integer "size"
    t.integer "parent_id"
    t.string  "thumbnail"
    t.integer "width"
    t.integer "height"
  end

  add_index "resources", ["parent_id"], :name => "index_on_parent_id"

  create_table "roles", :force => true do |t|
    t.string "title"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "index_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"

  create_table "styles", :force => true do |t|
    t.text    "stylesheet"
    t.integer "author_id"
    t.string  "name"
  end

  add_index "styles", ["author_id"], :name => "index_on_author_id"

  create_table "themes", :force => true do |t|
    t.string  "name"
    t.integer "style_id"
    t.integer "author_id"
    t.integer "print_style_id"
    t.string  "style_url"
    t.string  "print_style_url"
    t.string  "template"
  end

  add_index "themes", ["style_id"], :name => "index_on_style_id"
  add_index "themes", ["author_id"], :name => "index_on_author_id"
  add_index "themes", ["print_style_id"], :name => "index_on_print_style_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",    :limit => 40
    t.string   "salt",                :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "activation_code",     :limit => 40
    t.datetime "activated_at"
    t.string   "password_reset_code", :limit => 40
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "phone"
    t.string   "signup_domain"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "url"
    t.text     "about_me"
  end

end
