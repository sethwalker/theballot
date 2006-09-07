class CreatedAndUpdated < ActiveRecord::Migration
  def self.up
    add_column :guides, :created_at, :datetime
    add_column :guides, :updated_at, :datetime
    add_column :contests, :created_at, :datetime
    add_column :contests, :updated_at, :datetime
    add_column :choices, :created_at, :datetime
    add_column :choices, :updated_at, :datetime
  end

  def self.down
    remove_column :guides, :created_at
    remove_column :guides, :updated_at
    remove_column :contests, :created_at
    remove_column :contests, :updated_at
    remove_column :choices, :created_at
    remove_column :choices, :updated_at
  end
end
