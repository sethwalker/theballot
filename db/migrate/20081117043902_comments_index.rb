class CommentsIndex < ActiveRecord::Migration
  def self.up
    add_index :comments, :user_id, :name => 'index_comments_on_user_id'
  end

  def self.down
    remove_index :comments, :name => 'index_comments_on_user_id'
  end
end
