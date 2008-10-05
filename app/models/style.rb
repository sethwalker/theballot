class Style < ActiveRecord::Base
  has_many :themes
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
end
