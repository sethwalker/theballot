class Theme < ActiveRecord::Base
  has_many :guides
  belongs_to :style
end
