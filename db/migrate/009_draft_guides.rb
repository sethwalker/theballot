class DraftGuides < ActiveRecord::Migration
  def self.up
    g = Guide.new
    if g.respond_to?('create_draft_table')
      Guide.create_draft_table :force => true
      add_column Guide.draft_table_name, :endorsements, :text
    end
  end

  def self.down
    if g.respond_to?('drop_draft_table')
      Guide.drop_draft_table
    end
  end
end
