class Endorsement < ActiveRecord::Base
  belongs_to :position
  belongs_to :guide
end
