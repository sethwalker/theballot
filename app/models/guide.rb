class Guide < ActiveRecord::Base
  has_many :endorsements
  belongs_to :owner
  belongs_to :theme

  validates_presence_of :name, :city, :state

  def to_liquid
    { 'id' => id, 'name' => name, 'city' => city, 'state' => state, 'date' => date, 'description' => description, 'endorsements' => endorsements }
  end

end
