class CommentIndexes < ActiveRecord::Migration
  def self.up
    add_index :comments, :guide_id, :name => 'index_comments_on_guide_id'
    add_index :comments, :created_at, :name => 'index_comments_on_created_at'
  end

  def self.down
    remove_index :comments, :name => 'index_comments_on_created_at'
    remove_index :comments, :name => 'index_comments_on_guide_id'
  end
end
