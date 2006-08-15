class Theme < ActiveRecord::Base
  has_many :guides
  belongs_to :style
  has_one :screenshot, :dependent => :destroy
  belongs_to :print_style, :class_name => 'Style', :foreign_key => 'print_style_id'
end
