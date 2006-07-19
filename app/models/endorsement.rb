class Endorsement < ActiveRecord::Base
  belongs_to :position
  belongs_to :guide

  acts_as_list :column => 'sort', :scope => :guide

#  acts_as_draftable :fields => [:guide_id, :contest, :candidate, :position_id, :description]

  def to_liquid
    { 'contest' => contest, 'candidate' => candidate, 'description' => description, 'position' => position.text }
  end
end
