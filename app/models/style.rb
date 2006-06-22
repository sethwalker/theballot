class Style < ActiveRecord::Base
  has_one :template
  belongs_to :author, :class_name => 'User'
end
