class GuideApproval < ActiveRecord::Migration
  def self.up
    add_column :guides, :approved_at, :datetime
    add_column :guides, :approved_by, :integer
  end

  def self.down
    remove_column :guides, :approved_at
    remove_column :guides, :approved_by
  end
end
