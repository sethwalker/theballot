class AddPermalinks < ActiveRecord::Migration
  def self.up
    add_column :guides, :permalink, :string
  end
  
  def self.down
    remove_column :guides, :permalink
  end
  
end
