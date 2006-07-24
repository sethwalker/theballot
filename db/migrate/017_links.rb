class Links < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.column :url, :string
      t.column :description, :text
      t.column :guide_id, :integer
    end
  end

  def self.down
    drop_table :links
  end
end
