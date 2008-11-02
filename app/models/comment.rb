class Comment < ActiveRecord::Base
  belongs_to :guide
  belongs_to :user
  validates_presence_of :guide_id, :body
  named_scope :recent, :order => 'comments.created_at DESC', :include => :guide, :conditions => "guides.id"
end
