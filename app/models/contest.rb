class Contest < ActiveRecord::Base
  belongs_to :guide
  has_many :choices, :dependent => :destroy, :order => 'choices.position'
  acts_as_list :scope => :guide

  validates_uniqueness_of :name, :scope => :guide_id, :message => 'already added to this guide.  To edit that office, close this window and click the edit link for that office.'
  validates_associated :choices
  validates_presence_of :name

  def to_liquid
    { 'name' => name, 'choices' => choices }
#    { 'contest' => contest, 'candidate' => candidate, 'description' => description, 'selection' => selection, 'position' => position }
  end
end
