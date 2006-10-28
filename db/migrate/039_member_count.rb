class MemberCount < ActiveRecord::Migration
  def self.up
    add_column :guides, :num_members, :integer
    Guide.reset_column_information
    Guide.find(:all).each do |g|
      g.update_attribute(:num_members, g.members.count)
    end
  end

  def self.down
    remove_column :guides, :num_members
  end
end
