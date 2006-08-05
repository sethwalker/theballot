class EndorsedGuides < ActiveRecord::Migration
  def self.up
    add_column :guides, :endorsed, :boolean
  end

  def self.down
    remove_column :guides, :endorsed
  end
end
