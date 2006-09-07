class Choice < ActiveRecord::Base
  belongs_to :contest
  acts_as_list :scope => :contest

  validates_presence_of :name, :if => Proc.new {|choice| 'Candidate' == choice.contest.class}

  def validate
    errors.add :selection, 'no candidate endorsements for c3 guides' if Guide::C3 == contest.guide.legal && 'Candidate' == contest.class && selection
  end

  YES = 'Yes'
  NO = 'No'
  NO_ENDORSEMENT = 'No Endorsement'
  SELECTION_OPTIONS = {:yes => YES, :no => NO, :no_endorsement => NO_ENDORSEMENT }

  def self.options
    SELECTION_OPTIONS
  end

  def to_liquid
    { 'title' => title, 'description' => description, 'selection' => selection }
  end
end
