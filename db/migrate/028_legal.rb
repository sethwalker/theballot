class Legal < ActiveRecord::Migration
  def self.up
    add_column :guides, :legal, :string
  end

  def self.down
    remove_column :guides, :legal
  end
end
