class Guide < ActiveRecord::Base
  has_many :endorsements
  belongs_to :owner

  validates_presence_of :name, :city, :state
end
