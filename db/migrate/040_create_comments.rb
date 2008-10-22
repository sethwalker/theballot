class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      # t.column :name, :string
      t.column :subject, :string
      t.column :body, :text
      t.column :user_id, :integer
      t.column :guide_id, :integer
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :comments
  end
end
