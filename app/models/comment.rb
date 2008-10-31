class Comment < ActiveRecord::Base
  belongs_to :guide
  belongs_to :user
  named_scope :recent, :order => 'comments.created_at DESC', :include => :guide, :conditions => "guides.id"
end
