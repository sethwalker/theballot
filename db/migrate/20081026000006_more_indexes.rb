class MoreIndexes < ActiveRecord::Migration
  def self.up
    add_index :guides, ['status', 'approved_at', 'legal'], :name => 'index_on_stat_approv_legal'
  end

  def self.down
    remove_index :guides, :name => 'index_on_stat_approv_legal'
  end
end
