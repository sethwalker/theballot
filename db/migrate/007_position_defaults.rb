class PositionDefaults < ActiveRecord::Migration
  def self.up
    if !Position.count
      Position.create(:text => 'yes')
      Position.create(:text => 'no')
    end
  end

  def self.down
  end
end
