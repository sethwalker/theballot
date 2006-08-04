class UserAttachments < ActiveRecord::Migration
  def self.up
    add_column :attachments, :user_id, :integer
  end

  def self.down
    remove_column :attachments, :user_id
  end
end
