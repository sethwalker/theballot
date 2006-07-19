class GuideStateField < ActiveRecord::Migration
  def self.up
    add_column :guides, :status, :string
  end

  def self.down
    remove_column :guides, :status
  end
end
