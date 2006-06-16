class GuidesAndEndorsements < ActiveRecord::Migration
  def self.up
    create_table :guides do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :city, :string
      t.column :state, :string
    end

    create_table :endorsements do |t|
      t.column :guide_id, :integer
      t.column :contest, :string
      t.column :candidate, :string
      t.column :position_id, :integer
      t.column :description, :text
    end

    create_table :positions do |t|
      t.column :text, :string
    end
  end

  def self.down
    drop_table :guides
    drop_table :endorsements
    drop_table :positions
  end
end
