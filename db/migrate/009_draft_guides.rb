class DraftGuides < ActiveRecord::Migration
  def self.up
    Guide.create_draft_table :force => true
    add_column Guide.draft_table_name, :endorsements, :text
  end

  def self.down
    Guide.drop_draft_table
  end
end
