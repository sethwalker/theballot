class VoterBlocs < ActiveRecord::Migration
  def self.up
    create_table :pledges do |t|
      t.column :user_id, :integer
      t.column :guide_id, :integer
    end
  end

  def self.down
    drop_table :pledges
  end
end
