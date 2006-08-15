class StyleNames < ActiveRecord::Migration
  def self.up
    add_column :styles, :name, :string
  end

  def self.down
    remove_column :styles, :name
  end
end
