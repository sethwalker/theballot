class Comment < ActiveRecord::Base
  belongs_to :guide
  belongs_to :user
  validates_presence_of :guide_id, :body
  named_scope :recent, :order => 'comments.created_at DESC', :include => :guide, :conditions => "guides.id"
  named_scope :published, :include => :guide, :conditions => ["guides.status = ?", Guide::PUBLISHED]
  named_scope :approved, :include => :guide, :conditions => ["guides.approved_at IS NOT NULL OR legal IS NULL OR legal != ?", Guide::NONPARTISAN]
end
