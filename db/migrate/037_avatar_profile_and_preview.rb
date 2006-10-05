class AvatarProfileAndPreview < ActiveRecord::Migration
  def self.up
    Avatar.find(:all, :conditions => 'parent_id IS NULL').each do |a|
      a.create_or_update_thumbnail(:profile, '300>x300>')
      a.create_or_update_thumbnail(:preview, '150>x150>')
    end
  end

  def self.down
    Avatar.find_all_by_thumbnail('profile').each do |a|
      a.destroy
    end
    Avatar.find_all_by_thumbnail('preview').each do |a|
      a.destroy
    end
  end
end
