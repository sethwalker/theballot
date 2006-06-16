class ElectionDates < ActiveRecord::Migration
  def self.up
    add_column :guides, :date, :date
  end

  def self.down
    remove_column :guides, :date
  end
end
