class OrderedEndorsements < ActiveRecord::Migration
  def self.up
    add_column :endorsements, :position, :integer
  end

  def self.down
    remove_column :endorsements, :position
  end
end
