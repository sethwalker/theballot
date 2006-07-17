class Image < Attachment
  acts_as_attachment :content_type => :image, :thumbnails => { :thumb => [50, 50] }
  validates_as_attachment
  belongs_to :guide
end
