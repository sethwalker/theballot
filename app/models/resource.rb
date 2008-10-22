class Resource < ActiveRecord::Base
  has_attachment :storage => :file_system
end
