class PositionDefaults < ActiveRecord::Migration
  def self.up
    begin
      if !Position.count
        Position.create(:text => 'yes')
        Position.create(:text => 'no')
      end
    rescue
    end
  end

  def self.down
  end
end
