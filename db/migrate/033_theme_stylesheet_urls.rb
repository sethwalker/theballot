class ThemeStylesheetUrls < ActiveRecord::Migration
  def self.up
    add_column :themes, :style_url, :string
    add_column :themes, :print_style_url, :string
  end

  def self.down
    remove_column :themes, :style_url
    remove_column :themes, :print_style_url
  end
end
