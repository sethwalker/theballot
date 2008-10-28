class Comment < ActiveRecord::Base
  belongs_to :guide
  belongs_to :user
  named_scope :recent, :order => 'created_at DESC'
end
