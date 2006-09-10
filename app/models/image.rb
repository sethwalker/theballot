class Image < Attachment
  acts_as_attachment :content_type => :image, :thumbnails => { :thumb => [35, 35], :display => [50, 50] }
  validates_as_attachment
  belongs_to :guide
  belongs_to :user
end
