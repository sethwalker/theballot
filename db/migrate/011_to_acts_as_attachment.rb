class ToActsAsAttachment < ActiveRecord::Migration
  def self.up
    create_table :attachments, :force => true do |t|
      t.column "content_type", :string
      t.column "filename", :string     
      t.column "size", :integer

      # only for thumbnails
      t.column "parent_id",  :integer 
      t.column "thumbnail", :string

      # only for images (optional)
      t.column "width", :integer  
      t.column "height", :integer

      # try for some STI here
      t.column "type", :string

      t.column :guide_id, :integer
    end 
  end

  def self.down
    drop_table :attachments
  end
end
