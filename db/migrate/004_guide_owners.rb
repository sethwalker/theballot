class GuideOwners < ActiveRecord::Migration
  def self.up
    add_column :guides, :owner_id, :integer
  end

  def self.down
    remove_column :guides, :owner_id
  end
end
