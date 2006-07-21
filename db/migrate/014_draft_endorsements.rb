class DraftEndorsements < ActiveRecord::Migration
  def self.up
    e = Endorsement.new
    if e.respond_to?('create_draft_table')
      Endorsement.create_draft_table
    end
  end

  def self.down
    e = Endorsement.new
    if e.respond_to?('drop_draft_table')
      Endorsement.drop_draft_table
    end
  end
end
