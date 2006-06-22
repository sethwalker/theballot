class StylesAndTemplates < ActiveRecord::Migration
  def self.up
    create_table :styles do |t|
      t.column :stylesheet, :text
      t.column :author_id, :integer
    end

    create_table :themes do |t|
      t.column :name, :string
      t.column :markup, :text
      t.column :style_id, :integer
      t.column :author_id, :integer
    end

    add_column :guides, :theme_id, :integer
  end

  def self.down
    drop_table :styles
    drop_table :themes
    remove_column :guides, :theme_id
  end
end
