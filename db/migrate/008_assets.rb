class Assets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.column :type, :string
      t.column :content_type, :string
      t.column :filename, :string
      t.column :path, :string
    end

    create_table :assets_themes, :id => false do |t|
      t.column :asset_id, :integer
      t.column :theme_id, :integer
    end
  end

  def self.down
    drop_table :assets
    drop_table :assets_themes
  end
end
