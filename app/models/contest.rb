class Contest < ActiveRecord::Base
  belongs_to :guide
  has_many :choices, :dependent => :destroy, :order => 'choices.position'
  acts_as_list :scope => :guide

  validates_uniqueness_of :name, :scope => :guide_id, :message => 'is already added to the guide!'
  validates_associated :choices

  def to_liquid
    { 'contest' => name }
#    { 'contest' => contest, 'candidate' => candidate, 'description' => description, 'selection' => selection, 'position' => position }
  end
end
