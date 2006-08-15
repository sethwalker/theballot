class ThemeScreenshots < ActiveRecord::Migration
  def self.up
    add_column :attachments, :theme_id, :integer
  end

  def self.down
    remove_column :attachments, :theme_id
  end
end
