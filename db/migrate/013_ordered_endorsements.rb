class OrderedEndorsements < ActiveRecord::Migration
  def self.up
    add_column :endorsements, :sort, :integer
  end

  def self.down
    remove_column :endorsements, :sort
  end
end
