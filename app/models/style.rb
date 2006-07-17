class Style < ActiveRecord::Base
  has_one :theme
  belongs_to :author, :class_name => 'User'
end
