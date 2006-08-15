class PrintStyles < ActiveRecord::Migration
  def self.up
    add_column :themes, :print_style_id, :integer
  end

  def self.down
    remove_column :themes, :print_style_id
  end
end
