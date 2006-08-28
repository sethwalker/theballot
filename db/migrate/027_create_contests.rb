class CreateContests < ActiveRecord::Migration
  def self.up
    create_table :contests do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :type, :string
      t.column :guide_id, :integer
      t.column :position, :integer
    end
    create_table :choices do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :selection, :string
      t.column :contest_id, :integer
      t.column :position, :integer
    end
    Endorsement.find(:all).each do |e|
      begin
        contest = Contest.create!(:name => e.contest, :guide => e.guide, :position => e.position, :type => e.candidate ? 'Candidate' : 'Referendum')
        choice = Choice.create!(:name => e.candidate, :description => e.description, :selection => e.selection, :contest => contest)
      rescue
      end
    end

  end

  def self.down
    drop_table :contests
    drop_table :choices
  end
end
