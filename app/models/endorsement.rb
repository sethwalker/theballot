class Endorsement < ActiveRecord::Base
  YES = 'Yes'
  NO = 'No'
  NO_ENDORSEMENT = 'No Endorsement'
  SELECTION_OPTIONS = {:yes => YES, :no => NO, :no_endorsement => NO_ENDORSEMENT }

  def self.options
    SELECTION_OPTIONS
  end

  def selection_text
    SELECTION_OPTIONS[selection]
  end

  belongs_to :guide

  acts_as_list :scope => :guide

#  acts_as_draftable :fields => [:guide_id, :contest, :candidate, :position_id, :description]

  def to_liquid
    { 'contest' => contest, 'candidate' => candidate, 'description' => description, 'selection' => selection, 'position' => position }
  end
end
