class Endorsement < ActiveRecord::Base
  belongs_to :position
  belongs_to :guide

  def to_liquid
    { 'contest' => contest, 'candidate' => candidate, 'description' => description, 'position' => position.text }
  end
end
