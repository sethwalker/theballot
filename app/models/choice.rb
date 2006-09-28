class Choice < ActiveRecord::Base
  belongs_to :contest
  acts_as_list :scope => :contest

  validates_presence_of :name, :if => Proc.new {|choice| (Candidate == choice.contest.class)}

  YES = 'Yes'
  NO = 'No'
  NO_ENDORSEMENT = 'No Endorsement'
  SELECTION_OPTIONS = {:yes => YES, :no => NO, :no_endorsement => NO_ENDORSEMENT }

  def self.options
    SELECTION_OPTIONS
  end

  def to_liquid
    liquid = { 'name' => name, 'description' => description }
    liquid.merge!('selection' => selection) unless c3?
    liquid
  end

  def c3?
    contest.c3?
  end
end
