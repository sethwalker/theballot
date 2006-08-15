class Style < ActiveRecord::Base
  has_many :themes
  belongs_to :author, :class_name => 'User'
end
