class PositionsToOptions < ActiveRecord::Migration
  def self.up
    add_column :endorsements, :selection, :string
    begin
      Endorsement.find(:all).each do |e|
        if e.position.text.downcase == 'no'
          e.selection = 'No'
        else
          e.selection = 'Yes'
        end
      end
    rescue
    end
    drop_table :positions
    remove_column :endorsements, :position_id
  end

  def self.down
    create_table :positions do |t|
      t.column :text, :string
    end
    add_column :endorsements, :position_id, :integer
    begin
      yes = Position.create(:text => 'Yes')
      no = Position.create(:text => 'No')
      no_endorsement = Position.create(:text => 'No Endorsement')
      Endorsement.find(:all).each do |e|
        if e.selection.downcase == 'yes'
          e.position = yes
        elsif e.selection.downcase == 'no'
          e.position = no
        else
          e.position = no_endorsement
        end
      end
    rescue
    end
    remove_column :endorsements, :selection
  end
end
