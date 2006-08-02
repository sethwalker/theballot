class RemoveOwner < ActiveRecord::Migration
  def self.up
    rename_column :guides, :owner_id, :user_id
  end

  def self.down
    rename_column :guides, :user_id, :owner_id
  end
end
