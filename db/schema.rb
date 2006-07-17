# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 11) do

  create_table "assets", :force => true do |t|
    t.column "type", :string
    t.column "content_type", :string
    t.column "filename", :string
    t.column "path", :string
  end

  create_table "assets_themes", :id => false, :force => true do |t|
    t.column "asset_id", :integer
    t.column "theme_id", :integer
  end

  create_table "attachments", :force => true do |t|
    t.column "content_type", :string
    t.column "filename", :string
    t.column "size", :integer
    t.column "parent_id", :integer
    t.column "thumbnail", :string
    t.column "width", :integer
    t.column "height", :integer
    t.column "type", :string
    t.column "guide_id", :integer
  end

  create_table "endorsements", :force => true do |t|
    t.column "guide_id", :integer
    t.column "contest", :string
    t.column "candidate", :string
    t.column "position_id", :integer
    t.column "description", :text
  end

  create_table "guide_drafts", :force => true do |t|
    t.column "guide_id", :integer
    t.column "updated_at", :datetime
    t.column "name", :string
    t.column "city", :string
    t.column "state", :string
    t.column "date", :date
    t.column "description", :text
    t.column "owner_id", :integer
    t.column "theme_id", :integer
    t.column "endorsements", :text
  end

  create_table "guides", :force => true do |t|
    t.column "name", :string
    t.column "description", :text
    t.column "city", :string
    t.column "state", :string
    t.column "date", :date
    t.column "owner_id", :integer
    t.column "theme_id", :integer
  end

  create_table "positions", :force => true do |t|
    t.column "text", :string
  end

  create_table "roles", :force => true do |t|
    t.column "title", :string
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.column "role_id", :integer
    t.column "user_id", :integer
  end

  create_table "styles", :force => true do |t|
    t.column "stylesheet", :text
    t.column "author_id", :integer
  end

  create_table "themes", :force => true do |t|
    t.column "name", :string
    t.column "markup", :text
    t.column "style_id", :integer
    t.column "author_id", :integer
  end

  create_table "users", :force => true do |t|
    t.column "login", :string
    t.column "email", :string
    t.column "crypted_password", :string, :limit => 40
    t.column "salt", :string, :limit => 40
    t.column "created_at", :datetime
    t.column "updated_at", :datetime
    t.column "activation_code", :string, :limit => 40
    t.column "activated_at", :datetime
  end

end
